import json
import subprocess
import re
import os

# Caminho para a raiz do projeto (um nível acima de infra_OS)
base_dir = os.path.abspath("..")

# 1. Obter os outputs do Terraform em JSON
print("Lendo IPs com Terraform...")
output = subprocess.run(["terraform", "output", "-json"], cwd=".", capture_output=True, text=True)
if output.returncode != 0:
    print("Erro ao executar 'terraform output -json'")
    print(output.stderr)
    exit(1)

data = json.loads(output.stdout)

# 2. Extrair IPs
frontend_ip = data["frontend_ip"]["value"]
database_ip = data["database_ip"]["value"]
load_balancer_ip = data["loadbalancer_ip"]["value"]

print(f"Frontend IP: {frontend_ip}")
print(f"Database IP: {database_ip}")
print(f"Load Balancer IP: {load_balancer_ip}")

# 3. Atualizar IP no backend/app.py
app_path = os.path.join(base_dir, "backend/app.py")
if os.path.exists(app_path):
    with open(app_path, "r") as f:
        content = f.read()

    updated = re.sub(r'http://[\d.]+', f'http://{frontend_ip}', content)

    with open(app_path, "w") as f:
        f.write(updated)

    print("IP do frontend atualizado no app.py")
else:
    print("backend/app.py não encontrado.")

# 4. Atualizar IP no backend/config.py
config_path = os.path.join(base_dir, "backend/config.py")
if os.path.exists(config_path):
    with open(config_path, "r") as f:
        content = f.read()

    updated = re.sub(
        r'postgresql://postgres:postgres@[\d.]+:5432/inapp_db',
        f'postgresql://postgres:postgres@{database_ip}:5432/inapp_db',
        content
    )

    with open(config_path, "w") as f:
        f.write(updated)

    print("IP da base de dados atualizado no config.py")
else:
    print("backend/config.py não encontrado.")

# 5. Atualizar IP nos ficheiros HTML do frontend
html_files = [
    "cart.html", "index.html", "office.html", "payment.html", "sign-up.html"
]

for html_file in html_files:
    full_path = os.path.join(base_dir, "frontend", html_file)
    if os.path.exists(full_path):
        with open(full_path, "r") as f:
            content = f.read()

        updated_content = re.sub(
            r'const backendUrl = "http://[^"]+";',
            f'const backendUrl = "http://{load_balancer_ip}:80";',
            content
        )

        with open(full_path, "w") as f:
            f.write(updated_content)

        print(f"IP do backend atualizado em {html_file}")
    else:
        print(f"{html_file} não encontrado.")

print("Atualização de IPs concluída.")

# 6. Commit e push apenas dos diretórios backend e frontend
print("Enviando alterações para o repositório remoto...")

try:
    subprocess.run(["git", "add", "backend", "frontend"], cwd=base_dir, check=True)
    subprocess.run(["git", "commit", "-m", "Atualizar IPs com Terraform"], cwd=base_dir, check=True)
    subprocess.run(["git", "push", "origin", "master"], cwd=base_dir, check=True)
    print("Push para o Git concluído.")
except subprocess.CalledProcessError as e:
    print("Erro ao fazer git push:")
    print(e)
