[← Back to Main README](../README.md)

> **Prerequisite:** Review the [Requirements & Prerequisites](../README.md#-requirements--prerequisites) before customizing branding.

# Branding

This guide explains how to customize the look and feel of the Zammad interface and the public homepage.

## Customizing Zammad

Zammad supports theming and custom branding through its admin interface. Upload your logo and adjust colors under **Admin → Branding**. Changes are stored in the `zammad_data` volume and take effect after refreshing the page.

## Homepage Customization

The landing page served by NGINX is located at `services/nginx/html/index.html`. Edit this file and rebuild the `nginx` service to apply changes.

---
🔗 Back to [Main README](../README.md)  
📚 See also: [Deployment](deployment.md) | [Homepage](homepage.md)
