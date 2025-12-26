# docker-asterisk-ja

Docker container for Asterisk PBX with Japanese language support.

## Features

- Based on Debian Bookworm
- Japanese language sound files pre-installed
- Minimal footprint with unnecessary modules disabled
- Health check support
- Multi-architecture support (amd64, arm64)

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
  -p 10000-20000:10000-20000/udp \
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

### Configuration Files

The image includes default Asterisk configuration files. You can customize them by:

1. Extracting default files from the container (see Quick Start)
2. Editing them according to your needs
3. Mounting them as volumes when running the container

Key configuration files:
- **sip.conf** - SIP configuration
- **extensions.conf** - Dialplan configuration
- **voicemail.conf** - Voicemail users (optional)

### Port Mapping

- `5060/udp` - SIP signaling port
- `10000-20000/udp` - RTP media ports (adjust range as needed)

## Docker Compose

Copy the example compose file and start the service:

```bash
cp docker-compose.yml.example docker-compose.yml
docker-compose up -d
```

See `docker-compose.yml.example` for the configuration template.

## Pre-configured Settings

The image comes with the following pre-configured settings:

- **Language**: Japanese (ja)
- **Codecs**: ulaw, gsm
- **Voicemail**: WAV format, auto-delete enabled
- **Modules**: Unnecessary modules disabled for security and performance

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
