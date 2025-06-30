# 🚀 Zammad Ticketing Hostinger Project

Welcome! 👋

## Table of Contents
- [Project Vision](#-project-vision)
- [Goals](#-goals)
- [Technology Stack](#-technology-stack)
- [Learning Together](#-learning-together)
- [Next Steps & Contribution](#-next-steps--contribution)
- [Documentation](#-documentation)
- [Thank You](#-thank-you)

This repository represents my first step into the world of open-source collaboration, designed specifically to create a simple, secure, and easy-to-deploy ticketing system based on the open-source tool **Zammad**, hosted on a cost-effective VPS provider (**Hostinger**), and seamlessly integrated with **Microsoft 365**.

## 🎯 Project Vision

My name is Juraj, and at 31, I've decided to dive into a journey of learning, collaboration, and building something meaningful for myself and other small to mid-sized businesses. As an entrepreneur managing a mid-sized business, I'm often frustrated by the high costs associated with running custom software. My goal is to leverage the power of open-source solutions and streamline deployment with a CI/CD pipeline, enabling even those with limited technical experience (like myself!) to deploy and manage a robust ticketing solution efficiently.

I believe integrating the **Zammad** ticketing system with **Microsoft 365** is crucial due to its widespread adoption, robust security, and versatile tools (Outlook, SharePoint, Teams, etc.). This integration aims to enhance functionality, reduce complexity, and leverage existing organizational structures like Microsoft Groups and permissions.

Ultimately, I envision this project as a foundation—not just for ticketing—but potentially evolving into a customizable workflow automation platform tailored to individual company needs. Additionally, integrating a workflow automation tool like **n8n** in the future would be extremely powerful, allowing companies to create intricate, automated workflows that respond dynamically to various triggers and actions.

Another exciting future vision is integrating structured document handling capabilities. This would allow various documents uploaded into tickets or workflows to be processed systematically, enhancing functionality such as customer complaints handling and enabling advanced automated responses or actions based on document content.

In the longer term, I'm enthusiastic about exploring integrations with **AI agents and MCP (Model Context Protocol)**, creating a highly responsive and intelligent system that dynamically supports business operations, customer interactions, and internal processes. The ultimate goal is to empower businesses by providing meaningful, actionable automation that evolves alongside their needs.

## 🔑 Goals

* **Easy Deployment:** Deploy Zammad on a Hostinger VPS effortlessly via Jenkins CI/CD pipeline.
* **Secure Integration:** Seamlessly integrate with Microsoft 365 for authentication, email, and other productivity tools.
* **Cost-Effective Solution:** Offer businesses a practical alternative to expensive commercial solutions.
* **Learning and Growth:** Document extensively to foster learning and enable contributors of all skill levels to participate.

## 🛠️ Technology Stack

* **Zammad:** Open-source ticketing system.
* **Docker Compose:** Containerize and simplify deployments.
* **Jenkins:** Automate deployments with an existing CI/CD pipeline.
* **Microsoft 365:** OAuth authentication, email integration, Teams and SharePoint integration.
* **Hostinger VPS:** Affordable, reliable hosting.
* **n8n (Future integration):** Workflow automation tool for custom integrations and actions.
* **Structured Document Handling (Future integration):** Systematic processing and management of uploaded documents.
* **AI Agents & MCP (Future integration):** Intelligent, dynamic workflow automation and customer interaction enhancements.

## 📚 Learning Together

This project is not just about creating software—it's about learning, growing, and contributing together. I'm actively collaborating with freelance developers initially to set a solid foundation, guide structure, and ensure best practices.

Whether you're a seasoned developer, an enthusiastic learner, or simply passionate about helping businesses streamline their operations, your contributions, feedback, and knowledge-sharing are warmly welcomed!

## 🚧 Next Steps & Contribution

* Set up initial Docker Compose stack.
* Configure Jenkins pipeline and deployment scripts.
* Develop robust documentation for ease of use.
* Enhance and test Microsoft 365 integration features.

Feel free to open issues, suggest features, submit pull requests, or simply share your ideas!

## 📖 Documentation

All additional guides are stored in the [`docs/`](docs/) directory:

- **[deployment.md](docs/deployment.md)** – step-by-step instructions to run the Zammad stack with Docker Compose.
- **[ci-cd-pipeline.md](docs/ci-cd-pipeline.md)** – explains the Jenkins pipeline used for automated deployments.

These documents will grow alongside the project as more features (like Microsoft 365 integration or n8n workflows) are added.

## 🙏 Thank You!

Thank you for visiting this repository and potentially contributing your expertise or enthusiasm. Every contribution counts, and I'm grateful to anyone who joins me on this exciting learning journey.

Let's create something valuable together! 🌟

Juraj
