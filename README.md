# Projekt infrastruktury dwuwarstwowej w Azure (Terraform)

Projekt wykonany na potrzeby pracy inzynierskiej. Tworzy prosta architekture dwuwarstwowa (Two-Tier) w chmurze Microsoft Azure przy uzyciu Terraforma, z automatyczna konfiguracja aplikacji na obu warstwach.

## Architektura

Srodowisko sklada sie z nastepujacych elementow:
- Grupa zasobow: rg-azure-terraform (region: polandcentral)
- Siec wirtualna: vnet-main (pula 10.0.0.0/16)
- Podsiec webowa: subnet-web (10.0.1.0/24) z publicznym adresem IP
- Podsiec bazy danych: subnet-db (10.0.2.0/24) bez publicznego IP
- Zapory sieciowe NSG:
  - nsg-web: wpuszcza ruch na porty 80 (HTTP) i 22 (SSH) ze swiata
  - nsg-db: wpuszcza ruch na porty 3306 (MySQL) i 22 (SSH) tylko z podsieci web (10.0.1.0/24), reszta ruchu jest zablokowana
- Maszyny wirtualne (Ubuntu 22.04 LTS) z automatycznym provisioningiem przez custom_data (cloud-init):
  - vm-web: prywatny IP 10.0.1.4, posiada publiczny IP, dziala jako jump host; skrypt cloud-init tworzy 1GB plik swap, instaluje Docker Engine i uruchamia kontener WordPress polaczony z baza na 10.0.2.4:3306
  - vm-db: prywatny IP 10.0.2.4, tylko prywatny IP, pelna izolacja od zewnatrz; skrypt cloud-init tworzy 2GB plik swap (ochrona przed OOM na Standard_B1s), instaluje Docker Engine i uruchamia kontener MySQL 8.0 ze stalym wolumenem

Uwaga: Adresy maszyn maja koncowke .4, poniewaz Azure rezerwuje pierwsze cztery adresy w podsieci (.0 na adres sieci, .1 na brame, .2 i .3 na dns i uslugi azure) oraz ostatni .255 na broadcast.

## Struktura plikow

- providers.tf - konfiguracja terraforma i providera azurerm
- variables.tf - definicje zmiennych wejsciowych (wszystkie dane bazy bez wartosci domyslnych)
- terraform.tfvars.example - przykladowy szablon zmiennych z bezpiecznymi atrapami na github
- terraform.tfvars - lokalny plik z wlasnym subscription_id i danymi dostepowymi bazy (ignorowany przez git)
- network.tf - grupa zasobow, vnet, podsieci i publiczny ip
- security.tf - grupy nsg i przypiecie ich do podsieci
- compute.tf - karty sieciowe, maszyny wirtualne oraz podpiecie skryptow custom_data
- outputs.tf - wyswietlanie ip i gotowych polecen ssh
- scripts/cloud-init-web.tftpl - skrypt startowy tworzacy 1GB swap oraz instalujacy dockera i wordpressa na vm-web
- scripts/cloud-init-db.tftpl - skrypt startowy tworzacy 2GB swap oraz instalujacy dockera i mysql 8.0 na vm-db
- .gitignore - blokowanie plikow stanu, kluczy i lokalnych plikow *.tfvars

## Uruchomienie projektu

1. Zalogowanie do konta azure w terminalu:
az login

2. Przygotowanie lokalnego pliku terraform.tfvars na podstawie szablonu:
cp terraform.tfvars.example terraform.tfvars
Nastepnie nalezy uzupelnic w lokalnym terraform.tfvars wszystkie wymagane wartosci: subscription_id, db_name, db_user, db_password oraz db_root_password. Plik terraform.tfvars jest zablokowany w .gitignore, wiec sekrety nie trafia do repozytorium.

3. Inicjalizacja i wdrozenie infrastruktury:
terraform init
terraform apply
(zatwierdzic wpisujac yes)

4. Odczekanie na zakonczenie skryptow cloud-init:
Po zakonczeniu terraform apply w terminalu pojawia sie adresy IP oraz gotowe komendy SSH. Instalacja Dockera oraz pobranie obrazow WordPress i MySQL w tle trwa okolo 2-3 minut. Po tym czasie nalezy otworzyc w przegladarce adres http://<PUBLICZNY_IP_WEB> i zweryfikowac pojawienie sie ekranu instalatora WordPressa.

## Testowanie srodowiska

1. Weryfikacja dzialania aplikacji webowej (WordPress + polaczenie z MySQL):
Wejscie w przegladarce na http://<PUBLICZNY_IP_WEB> powinno wyswietlic instalator WordPressa, co potwierdza dzialanie kontenera na vm-web oraz komunikacje z baza MySQL na vm-db po porcie 3306.

2. Logowanie na maszyne webowa po SSH:
ssh azureuser@<PUBLICZNY_IP_WEB>

3. Logowanie na maszyne bazy danych przez jump host:
ssh -J azureuser@<PUBLICZNY_IP_WEB> azureuser@10.0.2.4

4. Sprawdzenie izolacji bazy danych od internetu:
ssh -o ConnectTimeout=5 azureuser@10.0.2.4
Polecenie zwroci blad braku trasy lub timeout, poniewaz baza nie ma publicznego IP i nie jest widoczna z internetu.

## Usuniecie zasobow

Aby nie generowac kosztow w subskrypcji, po zakonczeniu testow mozna usunac calosc poleceniem:
terraform destroy
(zatwierdzic wpisujac yes)
