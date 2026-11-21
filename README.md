# Projekt infrastruktury dwuwarstwowej w Azure (Terraform)

Projekt wykonany na potrzeby pracy inzynierskiej. Tworzy prosta architekture dwuwarstwowa (Two-Tier) w chmurze Microsoft Azure przy uzyciu Terraforma.

## Architektura

Srodowisko sklada sie z nastepujacych elementow:
- Grupa zasobow: rg-azure-terraform (region: polandcentral)
- Siec wirtualna: vnet-main (pula 10.0.0.0/16)
- Podsiec webowa: subnet-web (10.0.1.0/24) z publicznym adresem IP
- Podsiec bazy danych: subnet-db (10.0.2.0/24) bez publicznego IP
- Zapory sieciowe NSG:
  - nsg-web: wpuszcza ruch na porty 80 (HTTP) i 22 (SSH) ze swiata
  - nsg-db: wpuszcza ruch na porty 3306 (MySQL) i 22 (SSH) tylko z podsieci web (10.0.1.0/24), reszta ruchu jest zablokowana
- Maszyny wirtualne (Ubuntu 22.04 LTS):
  - vm-web: prywatny IP 10.0.1.4, posiada publiczny IP, dziala jako jump host oraz uruchamia kontener WordPress w Dockerze
  - vm-db: prywatny IP 10.0.2.4, tylko prywatny IP, pelna izolacja od zewnatrz

Uwaga: Adresy maszyn maja koncowke .4, poniewaz Azure rezerwuje pierwsze cztery adresy w podsieci (.0 na adres sieci, .1 na brame, .2 i .3 na dns i uslugi azure) oraz ostatni .255 na broadcast.

## Struktura plikow

- providers.tf - konfiguracja terraforma i providera azurerm
- variables.tf - definicje zmiennych wejsciowych
- terraform.tfvars.example - przykladowy szablon zmiennych na github
- terraform.tfvars - lokalny plik z wlasnym subscription_id i haslem do bazy
- network.tf - grupa zasobow, vnet, podsieci i publiczny ip
- security.tf - grupy nsg i przypiecie ich do podsieci
- compute.tf - karty sieciowe i maszyny wirtualne
- outputs.tf - wyswietlanie ip i gotowych polecen ssh
- scripts/cloud-init-web.tftpl - skrypt startowy instalujacy dockera i wordpressa na vm-web
- .gitignore - blokowanie plikow stanu i zmiennych z sekretami

## Uruchomienie projektu

1. Zalogowanie do konta azure w terminalu:
az login

2. Przygotowanie pliku terraform.tfvars ze swoim subscription_id oraz db_password:
cp terraform.tfvars.example terraform.tfvars

3. Inicjalizacja i wdrozenie infrastruktury:
terraform init
terraform apply
(zatwierdzic wpisujac yes)

Po zakonczeniu apply w terminalu pojawia sie adresy IP oraz gotowe komendy do logowania.

## Testowanie srodowiska

1. Logowanie na maszyne webowa po SSH:
ssh azureuser@<PUBLICZNY_IP_WEB>

2. Logowanie na maszyne bazy danych przez jump host:
ssh -J azureuser@<PUBLICZNY_IP_WEB> azureuser@10.0.2.4

3. Sprawdzenie izolacji bazy danych od internetu:
ssh -o ConnectTimeout=5 azureuser@10.0.2.4
Polecenie zwroci blad braku trasy lub timeout, poniewaz baza nie ma publicznego IP i nie jest widoczna z internetu.

## Usuniecie zasobow

Aby nie generowac kosztow w subskrypcji, po zakonczeniu testow mozna usunac calosc poleceniem:
terraform destroy
(zatwierdzic wpisujac yes)
