import subprocess
import json
import tempfile

SSH_KEY = "/home/ines/.ssh/id_rsa"

# 1. Obter IPs do Terraform
print("🔍 Lendo IPs do Terraform...")
output = subprocess.run(["terraform", "output", "-json"], capture_output=True, text=True)

if output.returncode != 0:
    print("❌ Erro ao obter os outputs do Terraform")
    print(output.stderr)
    exit(1)

data = json.loads(output.stdout)
backend_ips = data["backend_ips"]["value"]

# 2. Script remoto para correr app.py de forma segura
remote_script = """#!/bin/bash
cd ~/E_Commerce_App || exit 1
source ~/venv/bin/activate

# Garantir que a app não está a correr na porta 5000
PORT=5000
PID=$(lsof -ti tcp:$PORT)
if [ -n "$PID" ]; then
    echo "🔴 A matar processo existente na porta $PORT (PID=$PID)..."
    kill -9 $PID
    sleep 1
fi

# Atualizar código da aplicação
git pull origin master

# Iniciar a aplicação
cd backend || exit 1
nohup python3 app.py > /tmp/app.log 2>&1 &

# Verificar se a aplicação está a correr
echo "⏳ A verificar se a app está acessível em http://localhost:$PORT..."
for i in {1..10}; do
    if curl -s http://localhost:$PORT >/dev/null; then
        echo "✅ Backend está ativo!"
        exit 0
    fi
    sleep 1
done

echo "❌ Falha ao iniciar a aplicação no backend."
exit 1
"""

# 3. Enviar e executar remotamente em cada backend
def deploy_backend(ip):
    print(f"\n🚀 Iniciando backend em {ip}...")

    subprocess.run(["ssh-keygen", "-f", "/home/ines/.ssh/known_hosts", "-R", ip], check=False)

    # Criar script temporário
    with tempfile.NamedTemporaryFile("w", delete=False) as temp_script:
        temp_script.write(remote_script)
        temp_script_path = temp_script.name

    try:
        # Copiar script para a instância
        subprocess.run(
            ["scp", "-i", SSH_KEY, "-o", "StrictHostKeyChecking=no", temp_script_path, f"debian@{ip}:/tmp/run_backend.sh"],
            check=True
        )

        # Tornar executável e correr
        subprocess.run(
            f'ssh -o StrictHostKeyChecking=no -i {SSH_KEY} debian@{ip} "chmod +x /tmp/run_backend.sh && bash /tmp/run_backend.sh"',
            shell=True,
            check=True
        )

        print(f"✅ Backend iniciado com sucesso em {ip}")
    except subprocess.CalledProcessError as e:
        print(f"❌ Erro ao iniciar backend em {ip}: {e}")

# 4. Executar para cada backend
for ip in backend_ips:
    deploy_backend(ip)
