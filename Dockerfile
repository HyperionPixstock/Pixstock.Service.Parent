# docker build -t local/dockerdemo -f ./Dockerfile .

FROM microsoft/aspnetcore-build:latest AS build
WORKDIR /code

COPY pixstock.common.core pixstock.common.core
COPY pixstock.common.model pixstock.common.model
COPY pixstock.service.parent pixstock.service.parent
COPY pixstock.service.model pixstock.service.model
COPY pixstock.service.infra pixstock.service.infra
COPY pixstock.service.app pixstock.service.app
COPY pixstock.service.gateway pixstock.service.gateway
COPY pixstock.service.core pixstock.service.core
COPY pixstock.service.extention.sdk pixstock.service.extention.sdk

COPY pixstock.service.extention.fullbuild pixstock.service.extention.fullbuild
COPY pixstock.service.extention.webscribe pixstock.service.extention.webscribe

## 開発用のデータを含んだコンフィグ情報を設定する
COPY pixstock.service.parent/resources/development/ .

WORKDIR /code/pixstock.service.parent
RUN dotnet restore
RUN dotnet publish --output /output --configuration Debug


##############
## 2nd stage
FROM microsoft/aspnetcore:latest

COPY --from=build /output /app

# Extention
COPY --from=build /output/Pixstock.Service.Extention.FullBuild.dll /pixstock/extention/Pixstock.Service.Extention.FullBuild.pex
COPY --from=build /output/Pixstock.Service.Extention.Webscribe.dll /pixstock/extention/Pixstock.Service.Extention.Webscribe.pex

WORKDIR /app

ENV ASPNETCORE_ENVIRONMENT Development

ENTRYPOINT [ "dotnet", "Pixstock.Service.App.dll" ]
