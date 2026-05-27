# CADRE — Architecture Reference

## Topology

```mermaid
graph TB
    subgraph Internet[Internet / Host]
        VMH[VMware Workstation<br/>vmnet2: 192.168.77.1]
    end

    subgraph CORE[Core Domain Substrate — 7 VMs]
        subgraph cadre[ROOT: cadre.local — dc01 192.168.77.10]
        end
        subgraph child[CHILD: child.cadre.local — dc02 192.168.77.11]
        end
        subgraph ext[EXT: range.local — dc03 192.168.77.12]
        end

        mbr01[MBR01 — 192.168.77.22<br/>IIS + MSSQL<br/>child.cadre.local]
        mbr02[MBR02 — 192.168.77.23<br/>SCCM + MSSQL + WSUS + ADCS<br/>range.local]
        linux01[LINUX01 — 192.168.77.40<br/>MSSQL + NFS + Podman<br/>cadre.local]
        prov[PROVISIONING — 192.168.77.60<br/>Ansible<br/>Ubuntu 24.04]

        cadre <--> child
        cadre <--> ext
        cadre --- mbr01
        cadre --- linux01
        ext --- mbr02
    end

    subgraph EXTENSION[Extension Telemetry — 3 VMs]
        elk[ELK — 192.168.77.50<br/>Elasticsearch + Kibana<br/>Fleet Server]
        vr[VR — 192.168.77.51<br/>Velociraptor Server<br/>VQL Hunts]
        monitor[MONITOR — 192.168.77.55<br/>Zeek + Suricata + Arkime<br/>PCAP]
    end

    CORE --> EXTENSION
    VMH --- dc01
    VMH --- prov
    VMH --- elk
    VMH --- vr
    VMH --- monitor
```

## VM Specifications

| VM | vCPU | RAM | OS | Storage |
|----|:----:|:---:|----|:-------:|
| dc01 | 2 | 4 GB | Windows Server 2025 | 40 GB |
| dc02 | 2 | 4 GB | Windows Server 2025 | 40 GB |
| dc03 | 2 | 4 GB | Windows Server 2025 | 40 GB |
| mbr01 | 2 | 4 GB | Windows Server 2025 | 40 GB |
| mbr02 | 4 | 4 GB | Windows Server 2025 | 40 GB |
| linux01 | 2 | 4 GB | Ubuntu 24.04 | 40 GB |
| provisioning | 2 | 2 GB | Ubuntu 24.04 | 20 GB |
| elk | 6 | 12 GB | Ubuntu 24.04 | 60 GB (ES 6 GB heap) |
| vr | 2 | 4 GB | Ubuntu 24.04 | 40 GB |
| monitor | 4 | 8 GB | Ubuntu 24.04 | 60 GB |

## Data Flow

```mermaid
flowchart LR
    subgraph Sources[Telemetry Sources]
        W[5 Windows VMs<br/>WinRM + Elastic Agent]
        L[linux01<br/>Elastic Agent + auditd]
        Z[Zeek — monitor<br/>Network protocols]
        S[Suricata — monitor<br/>IDS alerts]
        V[Velociraptor — vr<br/>VQL hunts]
    end

    subgraph Sink[Elastic Stack]
        ES[Elasticsearch<br/>192.168.77.50:9200]
        KB[Kibana<br/>192.168.77.50:5601]
        FLEET[Fleet Server<br/>192.168.77.50:8220]
    end

    W --> FLEET
    L --> FLEET
    Z --> ES
    S --> ES
    V --> ES
    FLEET --> ES
    KB --> ES
```
