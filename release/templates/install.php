<?php
/**
 * Evolution API - Instalador Web (sem SSH)
 * Acesse: https://evolution.epage.app.br/install.php
 * Remova este arquivo apos concluir.
 */
declare(strict_types=1);

session_start();

$ROOT = __DIR__;
$LOCK = $ROOT . '/.install.lock';
$ENV_FILE = $ROOT . '/.env';
$SCHEMA = $ROOT . '/schema.sql';
$DIST_MAIN = $ROOT . '/dist/main.js';

function h(string $s): string
{
    return htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
}

function can_exec(): bool
{
    if (!function_exists('exec') && !function_exists('shell_exec')) {
        return false;
    }
    $disabled = array_map('trim', explode(',', (string) ini_get('disable_functions')));
    return !in_array('exec', $disabled, true) && !in_array('shell_exec', $disabled, true);
}

function run_cmd(string $cmd): array
{
    $out = [];
    $code = 1;
    if (function_exists('exec') && can_exec()) {
        exec($cmd . ' 2>&1', $out, $code);
    }
    return [$code, implode("\n", $out)];
}

function write_env(array $d): void
{
    global $ENV_FILE;
    $uriUser = rawurlencode($d['db_user']);
    $uriPass = rawurlencode($d['db_pass']);
    $uri = sprintf(
        'mysql://%s:%s@%s:%s/%s',
        $uriUser,
        $uriPass,
        $d['db_host'],
        $d['db_port'],
        $d['db_name']
    );

    $content = <<<ENV
SERVER_NAME=evolution
SERVER_TYPE=http
SERVER_PORT={$d['app_port']}
SERVER_URL={$d['server_url']}

AUTHENTICATION_API_KEY={$d['api_key']}
AUTHENTICATION_EXPOSE_IN_FETCH_INSTANCES=true
LANGUAGE=pt-BR

DEL_INSTANCE=false
CORS_ORIGIN=*
CORS_METHODS=GET,POST,PUT,DELETE
CORS_CREDENTIALS=true

LOG_LEVEL=ERROR,WARN,INFO
LOG_COLOR=true
LOG_BAILEYS=error

DATABASE_PROVIDER=mysql
DATABASE_CONNECTION_URI={$uri}
DATABASE_CONNECTION_CLIENT_NAME=evolution_api

DATABASE_SAVE_DATA_INSTANCE=true
DATABASE_SAVE_DATA_NEW_MESSAGE=true
DATABASE_SAVE_MESSAGE_UPDATE=true
DATABASE_SAVE_DATA_CONTACTS=true
DATABASE_SAVE_DATA_CHATS=true
DATABASE_SAVE_DATA_LABELS=true
DATABASE_SAVE_DATA_HISTORIC=true
DATABASE_SAVE_IS_ON_WHATSAPP=true
DATABASE_SAVE_IS_ON_WHATSAPP_DAYS=7
DATABASE_DELETE_MESSAGE=true

CACHE_REDIS_ENABLED={$d['redis_enabled']}
CACHE_REDIS_URI={$d['redis_uri']}
CACHE_REDIS_TTL=604800
CACHE_REDIS_PREFIX_KEY=evolution
CACHE_REDIS_SAVE_INSTANCES=false
CACHE_LOCAL_ENABLED=false

CONFIG_SESSION_PHONE_CLIENT=Evolution API
CONFIG_SESSION_PHONE_NAME=Chrome
QRCODE_LIMIT=30
QRCODE_COLOR='#175197'

RABBITMQ_ENABLED=false
WEBSOCKET_ENABLED=true
WEBSOCKET_GLOBAL_EVENTS=true
WEBSOCKET_ALLOWED_HOSTS=*
WEBHOOK_GLOBAL_ENABLED=false
S3_ENABLED=false
CHATWOOT_ENABLED=false
TYPEBOT_ENABLED=false
OPENAI_ENABLED=false
TELEMETRY_ENABLED=false
ENV;
    file_put_contents($ENV_FILE, $content);
}

function write_htaccess(int $port): void
{
    global $ROOT;
    $ht = <<<HT
# Evolution API - proxy para Node (cPanel / Apache)
<IfModule mod_rewrite.c>
RewriteEngine On

# Nao proxyar o instalador nem arquivos estaticos do PHP
RewriteRule ^install\\.php$ - [L]
RewriteRule ^\\.install\\.lock$ - [F]

RewriteCond %{HTTP:Upgrade} =websocket [NC]
RewriteRule ^(.*)$ ws://127.0.0.1:{$port}/\$1 [P,L]

RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^(.*)$ http://127.0.0.1:{$port}/\$1 [P,L]
</IfModule>
HT;
    file_put_contents($ROOT . '/.htaccess', $ht);
}

function import_schema(PDO $pdo, string $schemaFile): void
{
    $sql = file_get_contents($schemaFile);
    if ($sql === false) {
        throw new RuntimeException('Nao foi possivel ler schema.sql');
    }

    // Remove BOM (PowerShell/UTF-8) e normaliza quebras de linha
    $sql = preg_replace('/^\xEF\xBB\xBF/', '', $sql);
    $sql = str_replace(["\r\n", "\r"], "\n", $sql);

    // Remove comentarios de linha (-- ...)
    $sql = preg_replace('/^\s*--.*$/m', '', $sql);

    // Remove comentarios condicionais do mysqldump (/*!40101 ... */)
    $sql = preg_replace('/\/\*![0-9]{5}.*?\*\//s', '', $sql);

    // Remove comentarios de bloco restantes
    $sql = preg_replace('/\/\*.*?\*\//s', '', $sql);

    $pdo->exec('SET FOREIGN_KEY_CHECKS=0');

    $parts = preg_split('/;\s*\n/', $sql) ?: [];
    foreach ($parts as $part) {
        $part = trim($part);
        if ($part === '') {
            continue;
        }
        // Ignora SETs soltos
        if (preg_match('/^(SET|LOCK|UNLOCK)\b/i', $part)) {
            continue;
        }
        $pdo->exec($part);
    }

    $pdo->exec('SET FOREIGN_KEY_CHECKS=1');
}

$step = isset($_GET['step']) ? (int) $_GET['step'] : 1;
$errors = [];
$ok = [];
$locked = is_file($LOCK);

if ($locked && $step < 5) {
    $step = 5;
}

// Defaults do formulario
$defaults = [
    'server_url' => 'https://evolution.epage.app.br',
    'api_key' => bin2hex(random_bytes(16)),
    'db_host' => '127.0.0.1',
    'db_port' => '3306',
    'db_name' => 'db_evolution',
    'db_user' => 'us_evolution',
    'db_pass' => '',
    'app_port' => '8080',
    'redis_enabled' => 'true',
    'redis_uri' => 'redis://127.0.0.1:6379/0',
    'import_schema' => '1',
];

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !$locked) {
    $d = array_merge($defaults, array_map('trim', $_POST));
    $step = 3;

    if ($d['server_url'] === '' || $d['api_key'] === '' || $d['db_name'] === '' || $d['db_user'] === '') {
        $errors[] = 'Preencha URL, API Key, banco e usuario MySQL.';
    }
    if (!is_file($DIST_MAIN)) {
        $errors[] = 'Pasta dist/ incompleta. Envie o pacote completo do build-release.';
    }

    if (!$errors) {
        try {
            $dsn = sprintf(
                'mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
                $d['db_host'],
                $d['db_port'],
                $d['db_name']
            );
            $pdo = new PDO($dsn, $d['db_user'], $d['db_pass'], [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            ]);
            $ok[] = 'Conexao MySQL OK.';

            if (!empty($d['import_schema']) && is_file($SCHEMA)) {
                try {
                    import_schema($pdo, $SCHEMA);
                    $ok[] = 'Schema SQL importado.';
                } catch (Throwable $schemaErr) {
                    $ok[] = 'AVISO: schema automatico falhou. Importe schema.sql no phpMyAdmin. Detalhe: ' . $schemaErr->getMessage();
                }
            }

            write_env($d);
            $ok[] = 'Arquivo .env gravado.';

            write_htaccess((int) $d['app_port']);
            $ok[] = '.htaccess de proxy criado.';

            @mkdir($ROOT . '/instances', 0755, true);

            $npmDone = false;
            if (can_exec() && !is_dir($ROOT . '/node_modules')) {
                [$code, $out] = run_cmd('cd ' . escapeshellarg($ROOT) . ' && npm install --omit=dev --legacy-peer-deps');
                if ($code === 0) {
                    $ok[] = 'npm install concluido via PHP.';
                    $npmDone = true;
                    run_cmd('cd ' . escapeshellarg($ROOT) . ' && npx prisma generate --schema prisma/mysql-schema.prisma');
                } else {
                    $ok[] = 'AVISO: npm via PHP indisponivel. Use o Node.js App do painel para NPM Install + Start.';
                }
            }

            file_put_contents($LOCK, date('c') . "\nnpm=" . ($npmDone ? '1' : '0') . "\n");
            $step = 4;
            $_SESSION['install'] = $d;
        } catch (Throwable $e) {
            $errors[] = 'Erro: ' . $e->getMessage();
        }
    }
}

$install = $_SESSION['install'] ?? $defaults;
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Instalador Evolution API</title>
  <style>
    :root { --bg:#0a0a0a; --card:#171717; --text:#fafafa; --muted:#a1a1a1; --ok:#00ffa7; --err:#ff5c5c; --border:#262626; }
    * { box-sizing: border-box; }
    body { margin:0; font-family: system-ui, sans-serif; background:var(--bg); color:var(--text); }
    .wrap { max-width:720px; margin:40px auto; padding:0 16px; }
    h1 { font-size:1.5rem; margin:0 0 8px; }
    p { color:var(--muted); line-height:1.5; }
    .card { background:var(--card); border:1px solid var(--border); border-radius:12px; padding:20px; margin:16px 0; }
    label { display:block; font-size:.85rem; margin:12px 0 4px; color:var(--muted); }
    input, select { width:100%; padding:10px 12px; border-radius:8px; border:1px solid var(--border); background:#0a0a0a; color:var(--text); }
    .row { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
    button, .btn { display:inline-block; margin-top:16px; background:var(--ok); color:#000; border:0; padding:12px 18px; border-radius:8px; font-weight:700; cursor:pointer; text-decoration:none; }
    .err { background:#2a1212; border:1px solid var(--err); color:#ffb4b4; padding:12px; border-radius:8px; margin:8px 0; }
    .ok { background:#0d2a22; border:1px solid var(--ok); color:#b6ffe6; padding:12px; border-radius:8px; margin:8px 0; }
    code { background:#000; padding:2px 6px; border-radius:4px; }
    ol { color:var(--muted); line-height:1.7; }
    .check { margin:8px 0; }
    .check span { color:var(--ok); }
  </style>
</head>
<body>
<div class="wrap">
  <h1>Instalador Evolution API</h1>
  <p>Instalacao via navegador — sem SSH. Remova <code>install.php</code> apos concluir.</p>

  <div class="card">
    <div class="check"><?= is_file($DIST_MAIN) ? '<span>OK</span> dist/main.js' : '<b style="color:var(--err)">FALTA</b> dist/main.js' ?></div>
    <div class="check"><?= is_file($SCHEMA) ? '<span>OK</span> schema.sql' : '<b style="color:var(--err)">FALTA</b> schema.sql' ?></div>
    <div class="check"><?= is_file($ROOT . '/package.json') ? '<span>OK</span> package.json' : '<b style="color:var(--err)">FALTA</b> package.json' ?></div>
    <div class="check"><?= can_exec() ? '<span>OK</span> PHP pode executar comandos (npm opcional)' : 'PHP sem exec — use <b>Node.js App do cPanel</b> para iniciar' ?></div>
    <div class="check"><?= is_dir($ROOT . '/node_modules') ? '<span>OK</span> node_modules presente' : 'node_modules ausente (normal — instalar via cPanel)' ?></div>
  </div>

  <?php foreach ($errors as $e): ?><div class="err"><?= h($e) ?></div><?php endforeach; ?>
  <?php foreach ($ok as $m): ?><div class="ok"><?= h($m) ?></div><?php endforeach; ?>

  <?php if ($step <= 3 && !$locked): ?>
  <form method="post" class="card">
    <h2>1. Configuracao</h2>
    <label>URL publica da API</label>
    <input name="server_url" value="<?= h($install['server_url']) ?>" required>

    <label>API Key (header apikey)</label>
    <input name="api_key" value="<?= h($install['api_key']) ?>" required>

    <div class="row">
      <div>
        <label>MySQL host</label>
        <input name="db_host" value="<?= h($install['db_host']) ?>">
      </div>
      <div>
        <label>MySQL porta</label>
        <input name="db_port" value="<?= h($install['db_port']) ?>">
      </div>
    </div>
    <label>Nome do banco</label>
    <input name="db_name" value="<?= h($install['db_name']) ?>" required>
    <label>Usuario MySQL</label>
    <input name="db_user" value="<?= h($install['db_user']) ?>" required>
    <label>Senha MySQL</label>
    <input type="password" name="db_pass" value="<?= h($install['db_pass']) ?>">

    <div class="row">
      <div>
        <label>Porta Node (interna)</label>
        <input name="app_port" value="<?= h($install['app_port']) ?>">
      </div>
      <div>
        <label>Redis URI</label>
        <input name="redis_uri" value="<?= h($install['redis_uri']) ?>">
      </div>
    </div>

    <label>
      <input type="checkbox" name="import_schema" value="1" checked>
      Importar schema.sql agora (cria as tabelas)
    </label>

    <button type="submit">Instalar configuracao</button>
  </form>
  <?php endif; ?>

  <?php if ($step >= 4 || $locked): ?>
  <div class="card">
    <h2>2. Iniciar a API no cPanel (sem SSH)</h2>
    <p>O Apache so faz proxy. A Evolution API precisa de um processo Node ativo.</p>
    <ol>
      <li>No cPanel abra <b>Setup Node.js App</b> (ou Application Manager).</li>
      <li><b>Create Application</b>:
        <ul>
          <li>Node.js version: <b>20+</b></li>
          <li>Application root: pasta onde esta este instalador (ex: <code>evolution</code>)</li>
          <li>Application URL: <code>evolution.epage.app.br</code></li>
          <li>Application startup file: <code>dist/main.js</code></li>
          <li>Application mode: Production</li>
        </ul>
      </li>
      <li>Clique em <b>Run NPM Install</b> (se ainda nao houver node_modules).</li>
      <li>Em Environment Variables, confirme se o cPanel carrega o <code>.env</code>. Se nao, copie as chaves principais do arquivo <code>.env</code>.</li>
      <li>Clique em <b>Start / Restart</b>.</li>
      <li>Abra <a class="btn" href="/" target="_blank">https://evolution.epage.app.br/</a> — deve retornar JSON de boas-vindas.</li>
      <li>Manager: <code>/manager</code></li>
    </ol>
    <p><b>Importante:</b> Redis precisa estar ativo no servidor. Sem Redis, conexoes WhatsApp falham.</p>
  </div>

  <div class="card">
    <h2>3. Seguranca</h2>
    <p>Apague estes arquivos apos funcionar:</p>
    <ul>
      <li><code>install.php</code></li>
      <li><code>schema.sql</code> (opcional)</li>
    </ul>
    <?php if (is_file($LOCK)): ?>
      <p class="ok">Instalacao marcada como concluida (.install.lock).</p>
    <?php endif; ?>
  </div>
  <?php endif; ?>
</div>
</body>
</html>
