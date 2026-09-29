{{/*
Expand the name of the chart.
*/}}
{{- define "ztwim.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ztwim.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ztwim.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ztwim.labels" -}}
helm.sh/chart: {{ include "ztwim.chart" . }}
{{ include "ztwim.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ztwim.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ztwim.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Determine target namespace
*/}}
{{- define "ztwim.namespace" -}}
{{- if .Values.namespace }}
{{- printf "%s" .Values.namespace }}
{{- else }}
{{- printf "%s" .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
ArgoCD Syncwave, namespace and OperatorGroup
*/}}
{{- define "ztwim-operatorgroup.argocd-syncwave" -}}
{{- if and .Values.argocd .Values.argocd.enabled .Values.argocd.operatorgroup.syncwave -}}
argocd.argoproj.io/sync-wave: "{{ .Values.argocd.operatorgroup.syncwave }}"
{{- else }}
{{- "{}" }}
{{- end }}
{{- end }}

{{/*
ArgoCD Syncwave, Subscription
*/}}
{{- define "ztwim-operator.argocd-syncwave" -}}
{{- if and .Values.argocd .Values.argocd.enabled .Values.argocd.operator.syncwave -}}
argocd.argoproj.io/sync-wave: "{{ .Values.argocd.operator.syncwave }}"
{{- else }}
{{- "{}" }}
{{- end }}
{{- end }}

{{/*
ArgoCD Syncwave, operand custom resources
*/}}
{{- define "ztwim-operands.argocd-syncwave" -}}
{{- if and .Values.argocd .Values.argocd.enabled .Values.argocd.operands.syncwave -}}
argocd.argoproj.io/sync-wave: "{{ .Values.argocd.operands.syncwave }}"
{{- else }}
{{- "{}" }}
{{- end }}
{{- end }}

{{/*
Find the name of the OpenShift domain
*/}}
{{- define "ztwim.ocpDomain" -}}
{{- $ingresscontroller := (lookup "operator.openshift.io/v1" "IngressController" "openshift-ingress-operator" "default") | default dict }}
{{- $status := (get $ingresscontroller "status") | default dict }}
{{- $ocpDomain := (get $status "domain") | default dict }}
{{- printf "%s" $ocpDomain }}
{{- end }}

{{/*
Base URL of the SPIRE OIDC discovery endpoint. The provider creates the Route for it,
so this has to resolve to a host under the cluster's ingress domain.
*/}}
{{- define "ztwim.jwtIssuer" -}}
{{- if .Values.jwtIssuer }}
{{- printf "%s" .Values.jwtIssuer }}
{{- else }}
{{- printf "https://%s.%s" .Values.oidcDiscoveryLocalName (include "ztwim.ocpDomain" .) }}
{{- end }}
{{- end }}
