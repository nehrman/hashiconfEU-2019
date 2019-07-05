apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: ${name}
  namespace: ${namespace}
spec:
  secretName: ${secretname}
  issuerRef:
    name: vault-issuer
  commonName: ${dns_names}.${commonname}
  dnsNames:
  - ${dns_names}.${commonname}