# Browser Preview Knowledge

## Canonical preview setup

Project root:

```powershell
Set-Location c:\Users\andrvoicu\Desktop\repos\collectarr-app
```

Preferred script:

```powershell
.\scripts\run_web_for_copilot.ps1 -Port 7361 -Device chrome -Route /libraries?kind=manga -NoOpen
```

Manual fallback:

```powershell
flutter run -d chrome --web-hostname 127.0.0.1 --web-port 7361 --web-launch-url "http://127.0.0.1:7361/#/libraries?kind=manga"
```

## Fast health checks

Check the port:

```powershell
Get-NetTCPConnection -LocalPort 7361 -State Listen | Select-Object LocalAddress,LocalPort,OwningProcess
```

Expected behavior:
- if the page reload returns `ERR_CONNECTION_REFUSED`, the server is down
- if port `7361` is listening, reload the existing browser tab instead of opening a new one
- after a successful reload, the sandbox may show only `Enable accessibility`; that still confirms the Flutter app is live

## Known footguns

- Running `flutter run` from `c:\Users\andrvoicu\Desktop\repos` fails because there is no `pubspec.yaml` there.
- The existing shared browser tab should be reused whenever possible.
- Prefer the sandbox browser over the system browser unless the user explicitly asks otherwise.
