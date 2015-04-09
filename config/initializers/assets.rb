# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
Rails.application.config.assets.precompile += %w[
  application_cu.css
  application_hsl.css
  application_ns.css
  application_nyuad.css
  application_nyush.css
  nyulibraries/nyu/header.png
  nyulibraries/nyush/shanghai.png
  nyulibraries/nyuad/header.png
]
