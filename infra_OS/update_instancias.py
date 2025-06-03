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

# 2. SSH com git pull e cópia no frontend
def ssh_git_pull(ip, label, subdir=""):
    print(f"\n🔄 [{label}] Atualizando código em {ip}...")

    subprocess.run(["ssh-keygen", "-f", "/home/ines/.ssh/known_hosts", "-R", ip], check=False)

    if label == "frontend":
        remote_command = (
            "cd ~/E_Commerce_App && "
            "git pull origin master && "
            "sudo cp -r ~/E_Commerce_App/frontend/* /var/www/html/"
        )
    else:
        remote_command = f"cd ~/E_Commerce_App{subdir} && git pull origin master"

    try:
        result = subprocess.run(
            [
                "ssh",
                "-o", "StrictHostKeyChecking=no",
                "-i", SSH_KEY,
                f"debian@{ip}",
                remote_command
            ],
            capture_output=True,
            text=True
        )
        print(result.stdout)
        print(result.stderr)

        if result.returncode == 0:
            print(f"✅ [{label}] Código atualizado.")
        else:
            print(f"❌ [{label}] Falha ao atualizar código.")
    except Exception as e:
        print(f"❌ [{label}] Erro inesperado: {e}")

# 3. Executar para cada instância
for label, ip in instances.items():
    if "backend" in label:
        ssh_git_pull(ip, label, "/backend")
    else:
        ssh_git_pull(ip, label)
