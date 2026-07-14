# Fastlane — jobfinder

Sem Apple Developer Program. Lanes disponíveis:

| Lane | O que faz | Quando usar |
|------|-----------|-------------|
| `bundle exec fastlane ios lint` | Roda SwiftLint | Antes de commit/PR |
| `bundle exec fastlane ios test` | Roda testes (Swift Testing / XCTest) | CI / local |
| `bundle exec fastlane ios bootstrap` | Instala deps + gera `.xcodeproj` via XcodeGen | Setup inicial |
| `bundle exec fastlane ios build_ipa` | Gera IPA **assinado ad-hoc** (precisa de cert) | Distribuição interna |
| `bundle exec fastlane ios build_unsigned` | Gera IPA **sem assinatura** (CI default) | CI sem cert |
| `bundle exec fastlane ios release version:1.0.1` | Bump version + tag `v1.0.1` + push | Release |

## Variáveis de ambiente úteis

| Var | Default | Descrição |
|-----|---------|-----------|
| `SCHEME` | `jobfinder` | Nome do scheme |
| `CONFIGURATION` | `AdHoc` | Debug / Release / AdHoc |
| `BUMP_TYPE` | `patch` | patch / minor / major |
| `CODE_SIGNING_ALLOWED` | `NO` | YES → tenta ad-hoc, NO → sem signing |

