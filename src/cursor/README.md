# Cursor IDE

Web-based Cursor IDE with AI-powered coding assistant for Verily Workbench.

## Configuration

- **Image**: arfodublo/cursor-in-browser:latest-x64
- **Port**: 8080
- **User**: root
- **Home Directory**: /config

## Access

Once deployed in Workbench, access Cursor at the app URL (port 8080).

**Login:**
- Username: `cursor`
- Password: `changeme`

After logging in to the container, sign in with your Cursor account to activate AI features.

## Local Testing

```bash
docker network create app-network
docker run -d --name cursor-test --network app-network \
  -p 8080:8080 -e CUSTOM_USER=cursor -e PASSWORD=changeme \
  arfodublo/cursor-in-browser:latest-arm64  # Use latest-x64 for GCE
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

- **TESTING ONLY**: Using pinned community image (1.7.52-x64)
- **Security**: Requires InfoSec review before production use
- Requires Cursor account for AI features
- ARM64 version for local Mac testing, x64 for Workbench/GCE
- Containerization provides security isolation for AI code execution

## Production Readiness

⚠️ **Current Status: SPIKE/TESTING ONLY**

Before production deployment:
1. Security audit of Docker image
2. InfoSec approval required
3. Consider custom build from verified sources
4. See `PRODUCTION_ROADMAP.md` for details
