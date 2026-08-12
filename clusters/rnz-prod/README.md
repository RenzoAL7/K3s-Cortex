# rnz-prod

Raíz declarativa del clúster K3s en OCI.

Argo CD administra las aplicaciones declaradas en esta carpeta mediante el
patrón app-of-apps. GitPath sirve la experiencia de aprendizaje principal y
Cluster Signal observa el estado del clúster con permisos estrictamente de
lectura.
