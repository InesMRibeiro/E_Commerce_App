import subprocess
import json
import tempfile

SSH_KEY = "/home/ines/.ssh/id_rsa"

# 1. Obter IPs
print("🔍 Lendo IPs do Terraform...")
output = subprocess.run(["terraform", "output", "-json"], capture_output=True, text=True)

if output.returncode != 0:
    print("❌ Erro ao obter os outputs do Terraform")
    print(output.stderr)
    exit(1)

data = json.loads(output.stdout)
backend_ips = data["backend_ips"]["value"]

# 2. Script remoto a ser executado
remote_script = """
#!/bin/bash
cd ~/E_Commerce_App || exit 1
source ~/venv/bin/activate
cd backend || exit 1
pkill -f "app.py" || true
nohup python3 app.py > /tmp/app.log 2>&1 &
"""

# 3. Executa em cada instância
def deploy_backend(ip):
    print(f"\n🚀 Deploy para {ip}...")

    subprocess.run(["ssh-keygen", "-f", "/home/ines/.ssh/known_hosts", "-R", ip], check=False)

    with tempfile.NamedTemporaryFile("w", delete=False) as temp_script:
        temp_script.write(remote_script)
        temp_script_path = temp_script.name

    try:
        subprocess.run(
            ["scp", "-i", SSH_KEY, "-o", "StrictHostKeyChecking=no", temp_script_path, f"debian@{ip}:/tmp/run_backend.sh"],
            check=True
        )

        subprocess.run(
            f'ssh -o StrictHostKeyChecking=no -i {SSH_KEY} debian@{ip} "chmod +x /tmp/run_backend.sh && bash /tmp/run_backend.sh"',
            shell=True,
            check=True
        )

        print(f"✅ Backend iniciado com sucesso em {ip}")

    except subprocess.CalledProcessError as e:
        print(f"❌ Erro ao processar {ip}: {e}")

# 4. Correr para todos os backends
for ip in backend_ips:
    deploy_backend(ip)
