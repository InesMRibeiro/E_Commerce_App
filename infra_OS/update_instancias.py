import subprocess
import json

SSH_KEY = "/home/ines/.ssh/id_rsa"

# 1. Obter IPs do Terraform
print("🔍 Lendo IPs com Terraform...")
output = subprocess.run(["terraform", "output", "-json"], capture_output=True, text=True)

if output.returncode != 0:
    print("❌ Erro ao executar 'terraform output -json'")
    print(output.stderr)
    exit(1)

data = json.loads(output.stdout)

instances = {
    "frontend": data["frontend_ip"]["value"],
    "backend_1": data["backend_ips"]["value"][0],
    "backend_2": data["backend_ips"]["value"][1],
    "backend_3": data["backend_ips"]["value"][2],
}

# 2. Função para SSH com comando genérico
def ssh_execute(ip, label, command):
    print(f"\n🔄 [{label}] Atualizando instância {ip}...")

    subprocess.run(["ssh-keygen", "-f", "/home/ines/.ssh/known_hosts", "-R", ip], check=False)

    try:
        result = subprocess.run(
            f'ssh -o StrictHostKeyChecking=no -i {SSH_KEY} debian@{ip} "{command}"',
            shell=True,
            capture_output=True,
            text=True
        )
        print(result.stdout)
        print(result.stderr)

        if result.returncode == 0:
            print(f"✅ [{label}] Atualização concluída.")
        else:
            print(f"❌ [{label}] Erro ao atualizar {ip}.")
    except Exception as e:
        print(f"❌ [{label}] Falha: {e}")

# 3. Comandos por tipo de instância
for label, ip in instances.items():
    if "backend" in label:
        backend_cmd = """
        bash -c '
        cd ~/E_Commerce_App &&
        source ~/venv/bin/activate &&
        cd backend &&
        git pull origin master &&
        '
        """
        ssh_execute(ip, label, backend_cmd.strip())

    else:
        common_cmd = """
        bash -c '
        cd ~/E_Commerce_App &&
        git pull origin master
        '
        """
        ssh_execute(ip, label, common_cmd.strip())
