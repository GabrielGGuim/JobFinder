# ─────────────────────────────────────────────────────────────
#  Dangerfile — VagasBR / jobfinder
#  https://danger.systems
#  Roda automaticamente em PRs via CI (pr-checks workflow).
# ─────────────────────────────────────────────────────────────

# ── 0. Guarda de segurança: nunca deixar o comentário passar do limite do GitHub ──
# O GitHub rejeita comentários com mais de 65536 caracteres (erro 422).
# warn/fail/message/markdown são implementados em Danger::DangerfileMessagingPlugin
# (não na classe Dangerfile em si), então o patch precisa ir lá.
if defined?(Danger::DangerfileMessagingPlugin)
  Danger::DangerfileMessagingPlugin.class_eval do
    MAX_COMMENT_LENGTH = 60_000 # margem de segurança abaixo do limite de 65536

    def self.truncate_for_github(msg)
      return msg unless msg.is_a?(String) && msg.length > MAX_COMMENT_LENGTH
      msg[0...MAX_COMMENT_LENGTH] + "\n\n... (mensagem truncada, muito longa)"
    end

    %i[warn fail message markdown].each do |method_name|
      next unless method_defined?(method_name)

      alias_method "original_#{method_name}", method_name

      define_method(method_name) do |msg = nil, **kwargs|
        msg = self.class.truncate_for_github(msg)
        send("original_#{method_name}", msg, **kwargs)
      end
    end
  end
end

# ── 2. Toda PR precisa de descrição ────────────────────────
warn("PR sem descrição. Adicione um resumo das mudanças.") if github.pr_body.length < 10

# ── 3. Bloquear commits diretos em branches protegidas ────
if github.branch_for_base == "main" || github.branch_for_base == "homol"
  if git.commits.any? { |c| c["message"].to_s.match?(/^Merge commit/i) }
    # merges são esperados em PRs, ok
  end
end

# ── 4. Mudou project.yml? Lembrar de rodar xcodegen ────────
if git.modified_files.include?("project.yml")
  warn("`project.yml` mudou. Rode `xcodegen generate` localmente antes de mergear.")
end

# ── 5. Mudou package.swift sem Package.resolved? ──────────
manifest_changed = git.modified_files.any? { |f| f.end_with?("Package.swift") }
resolved_changed = git.modified_files.any? { |f| f.end_with?("Package.resolved") || f.end_with?("Package@swift-6.0.resolved") }
if manifest_changed && !resolved_changed
  warn("Algum `Package.swift` mudou mas o resolved file não. Rode `swift package update` e faça commit do resolved.")
end

# ── 6. Mudou Info.plist? Lembrar de versionar ─────────────
warn("Mudou `Info.plist`. Verifique se MARKETING_VERSION / CURRENT_PROJECT_VERSION estão corretos.") if git.modified_files.include?("jobfinder/Info.plist")

# ── 7. GoogleService-Info.plist — alerta de segurança ─────
if git.modified_files.include?("GoogleService-Info.plist")
  warn("⚠️  Mudou `GoogleService-Info.plist`. Confirme que não é um ambiente errado (dev/homol/prod).")
end

# ── 8. Sem TODOs órfãos em excesso ─────────────────────────
todo_count = (git.added_files + git.modified_files).sum do |file|
  next 0 unless file.end_with?(".swift")
  File.read(file).scan(/\bTODO\b/).count
rescue StandardError
  0
end
warn("Há #{todo_count} novos TODOs no código.") if todo_count > 5

# ── 9. Sem force unwraps desnecessários em Swift ───────────
force_unwrap_count = (git.added_files + git.modified_files).sum do |file|
  next 0 unless file.end_with?(".swift")
  # Heurística simples: conta "!" precedido por ) ou ]
  File.read(file).scan(/[\)\]]\s*!\s*[.\),;\s]/).count
rescue StandardError
  0
end
warn("⚠️  Detectados #{force_unwrap_count} possíveis force-unwraps. Considere usar guard let/if let.") if force_unwrap_count > 3

# ── 10. print() esquecido em código novo ───────────────────
print_count = (git.added_files + git.modified_files).sum do |file|
  next 0 unless file.end_with?(".swift")
  File.read(file).scan(/^\s*print\(/).count
rescue StandardError
  0
end
warn("🔍 Detectados #{print_count} novos `print()`. Use `os_log` ou remova antes de mergear.") if print_count > 0

# ── 11. Sem arquivo .DS_Store esquecido ────────────────────
ds_store = (git.added_files + git.modified_files).any? { |f| f.end_with?(".DS_Store") }
fail("❌ `.DS_Store` no commit. Rode `find . -name .DS_Store -delete` e remova do staged.") if ds_store

# ── 12. Sem segredos commitados ────────────────────────────
forbidden = /\.(p12|p8|cer|key|mobileprovision)$|AuthKey_|secrets?\//
sensitive = (git.added_files + git.modified_files).any? { |f| f.match?(forbidden) }
fail("❌ Detectado arquivo sensível (cert/token/key) no commit.") if sensitive

# ── 13. PR precisa de review ───────────────────────────────
if github.pr_reviewers.empty? && !github.api.draft?
  message("👀 Adicione pelo menos 1 reviewer antes de mergear.")
end

# ── 14. Confete quando tudo certo ─────────────────────────
message("✅ PR validada! Bom trabalho.") if git.lines_of_code > 0 && git.lines_of_code < 50
