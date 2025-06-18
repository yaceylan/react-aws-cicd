# Reflexion: CI/CD Pipeline mit Terraform & GitHub Actions

## Rollen der Jobs & Abhängigkeiten

- **ci_build**: Dieser Job baut die React-Anwendung. Er installiert die Abhängigkeiten, führt den Build aus und speichert das Ergebnis (den `dist/`-Ordner) als Artefakt.
- **infra_provision**: Dieser Job sorgt mit Terraform dafür, dass die nötige Infrastruktur (EC2-Instanz, VPC, etc.) bereitgestellt wird. Er hängt von `ci_build` ab, weil die App-Infrastruktur erst provisioniert werden soll, wenn der Build erfolgreich war.
- **app_deploy**: Dieser Job überträgt den fertigen React-Build via SSH auf die EC2-Instanz. Er benötigt sowohl das Build-Artefakt als auch eine fertig provisionierte Instanz, daher ist er abhängig von `infra_provision`.

Die `needs`-Anweisungen in der YAML-Datei sorgen dafür, dass diese Abhängigkeiten eingehalten werden. Jeder Job wartet auf den erfolgreichen Abschluss der vorherigen, bevor er startet.

## Artefakt-Übergabe

Das Artefakt (`dist/`) wurde im `ci_build`-Job mit `actions/upload-artifact` gespeichert und später im `app_deploy`-Job mit `actions/download-artifact` heruntergeladen.  
Das ist notwendig, weil die Jobs unabhängig voneinander laufen – ohne diese Übergabe gäbe es keinen Zugriff auf das gebaute Frontend im späteren Deployment.

## Umgang mit sensiblen Daten

AWS-Zugangsdaten und der SSH-Private Key wurden als GitHub Secrets gespeichert (`Settings > Secrets and variables`).  
Im Workflow wurden diese mit `${{ secrets.NAME }}` referenziert.  
Diese Methode ist sicherer als das Speichern im Code oder in unverschlüsselten Dateien, weil Secrets verschlüsselt sind, nicht in den Git-Verlauf geraten können und im Interface nicht sichtbar sind.

## IP-Ermittlung und Deployment

Die öffentliche IP der EC2-Instanz wurde von Terraform vergeben. Diese IP wurde über den Terraform Output automatisch mit `terraform output -raw public_ip` im `app_deploy`-Job abgefragt.  
Anschließend wurde `scp` verwendet, um die Dateien via SSH direkt nach `/var/www/html/` auf der EC2-Instanz zu kopieren.

## Änderungen ohne Destroy

Wenn nur Code in der React-App geändert wird und die Pipeline erneut läuft, bleibt die von Terraform verwaltete Infrastruktur unverändert – Terraform erkennt, dass keine Änderungen nötig sind.  
Nur das neue Build-Artefakt wird erstellt und auf die EC2-Instanz kopiert. Das spart Zeit und vermeidet unnötige Ressourcen-Neuerstellung.

## Sichtbarkeit der neuen App-Version

Innerhalb des `app_deploy`-Jobs wird der `dist/`-Ordner per `scp` auf die EC2-Instanz übertragen.  
Außerdem wird NGINX so konfiguriert, dass es den Inhalt aus `/var/www/html/` ausliefert.  
Das stellt sicher, dass bei jedem Deployment die aktuelle Version der React-App live geschaltet wird.

