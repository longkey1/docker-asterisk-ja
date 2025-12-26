# docker-asterisk-ja

Docker container for Asterisk PBX with Japanese language support.

**Asterisk Version**: 22.7.0

## Features

- Asterisk built from source (latest stable version)
- Based on Debian Trixie
- Japanese language sound files pre-installed
- Configurable language settings via environment variables
- Health check support
- Multi-architecture support (amd64, arm64)
- SMTP relay support via msmtp
- Multi-stage build for minimal image size

## Quick Start

### 1. Pull or build the image

```bash
# Option A: Pull from GitHub Container Registry
docker pull ghcr.io/longkey1/asterisk-ja:latest

# Option B: Build locally
docker build -t asterisk-ja .
```

### 2. Extract default configuration files

The Asterisk package includes default configuration files. Extract them for customization:

```bash
# Create a temporary container
docker create --name asterisk-temp ghcr.io/longkey1/asterisk-ja:latest

# Copy default config files
docker cp asterisk-temp:/etc/asterisk/sip.conf ./sip.conf
docker cp asterisk-temp:/etc/asterisk/extensions.conf ./extensions.conf
docker cp asterisk-temp:/etc/asterisk/voicemail.conf ./voicemail.conf

# Remove temporary container
docker rm asterisk-temp
```

Edit these files with your SIP provider credentials and dialplan configuration.

### 3. Run the container

```bash
docker run -d \
  --name asterisk \
  -p 5060:5060/udp \
  -p 10000-10200:10000-10200/udp \
  -e ASTERISK_LANGUAGE=ja \
  -v $(pwd)/sip.conf:/etc/asterisk/sip.conf:ro \
  -v $(pwd)/extensions.conf:/etc/asterisk/extensions.conf:ro \
  -v $(pwd)/voicemail.conf:/etc/asterisk/voicemail.conf:ro \
  asterisk-ja
```

### 4. Access Asterisk CLI

```bash
docker exec -it asterisk asterisk -r
```

## Configuration

### Environment Variables

The container supports the following environment variables:

- `ASTERISK_LANGUAGE` - Default language (default: `ja`)
  - Available: `en`, `es`, `fr`, `de`, `it`, `ja`, etc.
- `ASTERISK_LANGUAGE_PREFIX` - Enable language prefix (default: `yes`)
- `ASTERISK_TRANSMIT_SILENCE` - Transmit silence (default: `yes`)

Example:
```bash
docker run -e ASTERISK_LANGUAGE=en -e ASTERISK_LANGUAGE_PREFIX=no ...
```

### Configuration Files

The image includes default Asterisk configuration files. You can customize them by:

1. Extracting default files from the container (see Quick Start)
2. Editing them according to your needs
3. Mounting them as volumes when running the container

Key configuration files:
- **sip.conf** - SIP configuration
- **extensions.conf** - Dialplan configuration
- **voicemail.conf** - Voicemail users (optional)
- **msmtprc** - SMTP relay configuration (optional)

### Port Mapping

- `5060/udp` - SIP signaling port
- `10000-10200/udp` - RTP media ports (201 ports, suitable for ~50 concurrent calls)

## Docker Compose

Copy the example compose file and start the service:

```bash
cp docker-compose.yml.example docker-compose.yml
docker-compose up -d
```

See `docker-compose.yml.example` for the configuration template.

## Default Settings

The container applies the following default settings at startup (if not already configured):

- **Asterisk Version**: Built from official source (see VERSION file)
- **Language**: Japanese (ja) - configurable via `ASTERISK_LANGUAGE` environment variable
- **Sound Files**: Japanese language prompts pre-installed
- **Base Image**: Debian Trixie

All other Asterisk settings remain at their installation defaults. Customize by mounting your own configuration files.

## Image Tags

Images are tagged with Asterisk versions:
- `latest` - Latest Asterisk version
- `22.7.0` - Specific Asterisk version
- `22.7.0-20251226` - Version with build date
- `sha-xxxxxxx` - Git commit SHA

## Health Check

The container includes a health check that monitors:
- Asterisk process status
- CLI responsiveness

Check health status:

```bash
docker inspect --format='{{json .State.Health}}' asterisk
```

## Logs

View Asterisk logs:

```bash
docker logs -f asterisk
```

## License

This project configuration is based on the Ansible role from [elephant](https://github.com/longkey1/elephant).

---

Last updated: 2025-12-26T14:26:22+09:00
