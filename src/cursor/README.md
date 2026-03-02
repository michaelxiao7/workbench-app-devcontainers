# Cursor IDE

Web-based Cursor IDE with AI-powered coding assistant for Verily Workbench.

## Configuration

- **Image**: `arfodublo/cursor-in-browser:1.7.52-x64` (pinned community image)
- **Port**: 8080
- **User**: root
- **Home Directory**: /config

## Access

Once deployed in Workbench, access Cursor IDE at the app URL (port 8080).

**Login:**
- Username: `cursor`
- Password: `changeme`

After logging in, sign in with your Cursor account to activate AI features.

## Local Testing

```bash
# Create network and run
docker network create app-network
docker run -d --name cursor-test --network app-network \
  -p 8080:8080 \
  -e CUSTOM_USER=cursor -e PASSWORD=changeme \
  arfodublo/cursor-in-browser:1.7.52-x64
```

Access at: http://localhost:8080

## Customization

Edit `docker-compose.yaml` to change authentication credentials:

```yaml
environment:
  CUSTOM_USER: "your-username"
  PASSWORD: "your-password"
```

## Notes

- Uses community-maintained image (pinned to version 1.7.52)
- Custom Dockerfile available in `custom-dockerfile` branch
- Requires Cursor account for AI features

## Security Notes

✅ **This setup uses a Verily-controlled Dockerfile that:**

- Downloads Cursor from official source (downloads.cursor.com)
- Uses verified LinuxServer.io KasmVNC base image
- Follows the same pattern as VSCode-Docker template
- Provides full build transparency and audit trail

## Production Readiness

**Current Status: Using Community Image (Pinned)**

The `custom-dockerfile` branch contains a Verily-controlled Dockerfile for future production use.

Before production deployment:
1. Test custom Dockerfile build in Workbench
2. Security scan the built image
3. Verify Cursor enterprise licensing terms
