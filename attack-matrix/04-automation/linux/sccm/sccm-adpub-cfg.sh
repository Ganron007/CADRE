#!/bin/bash
# Check AD publishing config via SMS provider (svc_sccm) — CONFIG, from provisioning
WQ=/home/vagrant/campaign-venv/bin/wmiquery.py
cat > /tmp/adpub.q <<'EOF'
SELECT * FROM SMS_SCI_Component WHERE ComponentName='SMS_AD_UPDATE_COMPONENT'
SELECT * FROM SMS_SCI_Component WHERE ComponentName='SMS_AD_DISCOVERY_AGENT'
EOF
echo "=== AD update component + discovery ==="
$WQ -namespace '//./root/SMS/site_CAD' -file /tmp/adpub.q 'range/svc_sccm:s3rv1c3_SCCM!@192.168.77.23' 2>&1 | grep -iE 'ComponentName|ADForest|ADDomain|ADUser|ADPassword|interval|PropertyName|Value|error|Failed' | head -60
echo "=== Also query SMS_Identification / site properties for AD publish ==="
cat > /tmp/siteprop.q <<'EOF'
SELECT * FROM SMS_SCI_SiteDefinition
SELECT * FROM SMS_Site WHERE SiteCode='CAD'
EOF
$WQ -namespace '//./root/SMS/site_CAD' -file /tmp/siteprop.q 'range/svc_sccm:s3rv1c3_SCCM!@192.168.77.23' 2>&1 | grep -iE 'SiteCode|AD|Publish|Forest|Domain|error|Failed' | head -40
echo "ADPUB_DONE"
