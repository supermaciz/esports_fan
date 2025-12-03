# Technical exercise instructions

Please create a **GitHub repository** (private or public) containing a minimal Elixir/Phoenix/LiveView application. You may use the Phoenix generator to bootstrap the project. The application should include: 

- a **minimal user system**, with authentication generated via `mix phx.gen.auth.`
- a development seeding script that creates around **20,000 test users.**
- interaction with at least **one external API**
- an action that is executed **every N days** (the action itself can be mocked)
- a user-facing UI, using **Surface** and **Tailwind CSS** for at least part of the interface.

You are completely free to choose the domain of the project. But if you prefer a concrete suggestion, you can implement a weather application: after logging in, a component (using the [open-meteo.com](https://open-meteo.com/) API) displays a 7-day forecast for a given latitude and longitude. In addition, the app triggers a daily job (a mocked function call, not a real mailer) that “sends” an email to all users with the weather forecast of the day for their own latitude and longitude.

We are interested in **production-ready code**. Treat this as you would a small real-world project: the code should reflect how you ship features on a daily basis. We will look at your approach to data modelling, database usage, testing, error handling, structure of the application, and general best practices.

Your repository should include a **clear and concise README** explaining how to get started: prerequisites, how to set up the database (including seeds), how to run the application, etc. If there is anything you had to leave incomplete, or if there is a solution you would implement differently with more time, please describe your thought process and these missing parts in the README as well.

Take whatever time you need, we will not track when you start or finish. We would ideally like to receive your solution within **two weeks** of you receiving this exercise. You do **not** need to deploy the application or build a release. The goal is simply to have a concrete codebase to understand how you work, and to use as a basis for discussion in the next steps of the process.

Once your project is ready for review, please invite [github.com/goulvenclech](https://github.com/goulvenclech) to the repository, and notify us by email or LinkedIn that it is available.