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

# 2. Função para executar git pull via SSH
def ssh_git_pull(ip, label):
    print(f"\n🔄 [{label}] Atualizando repositório em {ip}...")

    # Remove entrada antiga do known_hosts
    subprocess.run(["ssh-keygen", "-f", "/home/ines/.ssh/known_hosts", "-R", ip], check=False)

    try:
        result = subprocess.run(
            f'ssh -o StrictHostKeyChecking=no -i {SSH_KEY} debian@{ip} '
            f'"cd ~/E_Commerce_App && git pull origin master"',
            shell=True,
            capture_output=True,
            text=True
        )
        print(result.stdout)
        print(result.stderr)

        if result.returncode == 0:
            print(f"✅ [{label}] Git pull concluído.")
        else:
            print(f"❌ [{label}] Erro ao atualizar {ip}.")
    except Exception as e:
        print(f"❌ [{label}] Falha inesperada: {e}")

# 3. Executar para todas as instâncias
for label, ip in instances.items():
    ssh_git_pull(ip, label)
