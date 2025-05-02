
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 7277
ENV ASPNETCORE_URLS=http://+:7277


FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY . .
RUN dotnet restore "eGlamHeelHangout/eGlamHeelHangout.csproj"
RUN dotnet build "eGlamHeelHangout/eGlamHeelHangout.csproj" -c Release -o /app/build


FROM build AS publish
RUN dotnet publish "eGlamHeelHangout/eGlamHeelHangout.csproj" -c Release -o /app/publish


FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "eGlamHeelHangout.dll"]
