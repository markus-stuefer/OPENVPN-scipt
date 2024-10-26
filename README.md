# OPENVPN-scipt
Das Skript vereinfacht die Einrichtung eines OpenVPN-Servers und konfiguriert grundlegende Netzwerk- und Sicherheitsanforderungen. Am Ende des Skripts wird eine Client-Konfigurationsdatei erstellt, die direkt an den Client übertragen werden kann, um eine Verbindung mit dem VPN-Server herzustellen.

1. System-Updates und Abhängigkeiten installieren
Systemaktualisierung: Es startet mit einem Update der Paketliste und installiert sicherheitsrelevante Upgrades.
OpenVPN und Easy-RSA: Installiert OpenVPN (VPN-Server-Software) und Easy-RSA, ein Tool zur Erstellung von SSL-Zertifikaten.
2. Konfiguration der Zertifizierungsstelle (CA)
Easy-RSA-Verzeichnis: Erstellt ein Verzeichnis für die CA und konfiguriert die Zertifikatsanforderungen mit Standardwerten.
CA erstellen: Generiert die Root-Zertifikate für die CA und ein Zertifikat für den Server selbst.
Client-Zertifikate: Zusätzlich wird ein Zertifikat für einen Client erstellt, das später zur Authentifizierung dient.
3. VPN-Server-Konfiguration
Kopieren der Zertifikate: Überträgt die Server-Zertifikate und Diffie-Hellman-Parameter in das OpenVPN-Verzeichnis.
Server-Konfiguration: Erstellt eine Konfigurationsdatei server.conf in /etc/openvpn/, die:
OpenVPN auf Port 1194 (UDP) betreibt,
die Datenverschlüsselung konfiguriert (SHA256 und AES-256),
Traffic-Weiterleitung und DNS-Optionen für VPN-Clients aktiviert,
sicherstellt, dass das VPN anonym (ohne Root-Rechte) läuft.
4. IP-Weiterleitung aktivieren
IP-Forwarding: Aktiviert das Routing von Datenverkehr über das VPN durch Anpassen der Systemparameter.
5. Firewall-Regeln einrichten
Firewall-Konfiguration: Erlaubt den Datenverkehr für OpenVPN (Port 1194) und SSH. Danach wird die Firewall aktiviert, um die Konfiguration zu schützen.
6. VPN-Dienst starten und aktivieren
OpenVPN-Dienst: Startet und aktiviert den OpenVPN-Dienst, sodass er bei jedem Neustart des Systems automatisch startet.
7. Client-Konfigurationsdatei erstellen
Client-Konfiguration: Erzeugt eine .ovpn-Datei (client.ovpn), die alle notwendigen Zertifikate und Einstellungen für den Client enthält. Diese Datei wird vom VPN-Client zum Verbinden mit dem Server verwendet.
Nutzung
Speichern Sie das Skript als Datei, zum Beispiel vpn-setup.sh.
Machen Sie das Skript ausführbar:
chmod +x vpn-setup.sh
Führen Sie das Skript mit Root-Berechtigungen aus:
sudo ./vpn-setup.sh
