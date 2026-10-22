{ inputs, ... }:
{
  flake.homeModules.noctalia-user = {
    imports = [ inputs.noctalia.homeModules.default ];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;

      # Nix attrset -> TOML, written to ~/.config/noctalia/config.toml.
      # Fine-tune from Noctalia's own settings UI at runtime, or here for
      # something you want to survive a `home-manager switch`.
      # See: https://docs.noctalia.dev/v5/
      settings = {
        shell.font = "JetBrainsMono Nerd Font";
        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Catppuccin";
        };

        # Both already default to `true` upstream — spelled out here since
        # fingerprint unlock only works because of a NixOS-side PAM choice
        # made to cooperate with it (../nixos/hardware/fingerprint.nix: the
        # `login` PAM service is deliberately fprintAuth-free so it doesn't
        # fight Noctalia's own D-Bus-driven fprintd reader claim on this lock
        # screen). Trigger a lock with `noctalia msg session lock` (bound to
        # Mod+L in modules/home/niri.nix) or the bar's "session" widget.
        lockscreen = {
          enabled = true;
          fingerprint = true;
        };

        # Single source of "where am I" — feeds weather, night light, and
        # theme auto mode. `auto_locate` (IP geolocation, api.noctalia.dev/
        # geolocate) rather than a geocoded `address`: manual `latitude`/
        # `longitude` here are NOT read by WeatherService at all — Noctalia's
        # weather only ever gets coordinates from LocationService's resolved
        # network lookup (confirmed by reading location_service.cpp /
        # weather_service.cpp upstream), and address-geocoding
        # (api.noctalia.dev/geocode) proved flaky/rate-limited even for a
        # bare "Porto" query. IP geolocation resolves reliably and lands in
        # the Porto metro area, which is what actually matters for weather.
        location = {
          auto_locate = true;
        };

        weather = {
          enabled = true;
          unit = "celsius";
        };

        # Only the toggle lives here — account credentials (Google OAuth
        # tokens, CalDAV passwords) are deliberately NOT declared in Nix.
        # They can't be: config.toml is a symlink into the read-only Nix
        # store, so Noctalia never writes discovered/added accounts back
        # into it. Account setup instead goes through Settings > Services >
        # Calendar Accounts (opens Google's OAuth browser flow, or takes a
        # CalDAV server/username/password for iCloud/custom), landing in the
        # app-writable ~/.config/noctalia/settings.toml overrides sidecar
        # and the system keyring (services.gnome.gnome-keyring, already
        # enabled in ../nixos/desktop/niri.nix) — same reasoning as the
        # glucose plugin's Dexcom credentials above.
        calendar.enabled = true;

        # `bar.main.end` is set wholesale, not appended to — this is
        # noctalia-shell's own default widget list (see its example.toml)
        # with our glucose plugin widget (below) tacked on at the end.
        # If a `home-manager switch` ever drifts from upstream's actual
        # default, diff against the newly pulled noctalia-shell's
        # example.toml before assuming this list is stale.
        bar.main.end = [
          "media"
          "tray"
          "notifications"
          "clipboard"
          "weather"
          "network"
          "bluetooth"
          "volume"
          "brightness"
          "battery"
          "control-center"
          "session"
          "dcosta/glucose:glucose"
          "dcosta/gpu-switch:gpu-switch"
        ];

        # Dropping plugin files under the local plugin dir (below) only
        # makes a plugin *discoverable* — noctalia-shell still requires its
        # id to be opted into `[plugins].enabled` before the widget factory
        # will register its widgets, regardless of whether it's referenced
        # from `bar.main.end` above. Without this, the bar logs "unknown
        # widget" and silently drops the entry.
        plugins.enabled = [
          "dcosta/glucose"
          "dcosta/gpu-switch"
        ];
      };
    };

    # Glucose bar widget, shipped as a local Noctalia Luau plugin
    # (docs.noctalia.dev's plugin API) rather than a built-in widget type —
    # Noctalia has no CGM support of its own. Dropped straight into its
    # plugin scan directory (~/.local/share/noctalia/plugins/<name>/), which
    # is auto-discovered with no separate "plugin source" registration
    # needed; `bar.main.end` above references it as "<manifest id>:<widget
    # id>" ("dcosta/glucose:glucose").
    #
    # Supports two sources, picked at runtime via the widget's own settings
    # screen: Dexcom Share (talks to Dexcom's own servers directly, no
    # self-hosted site needed — preferred) and Nightscout (fallback, for
    # when Share is unavailable). Deliberately NOT configured here: Dexcom
    # Share credentials / Nightscout URL and token. Fill those in from
    # Noctalia's Settings UI after rebuilding — same reasoning as mail.nix's
    # credentials: keep secrets out of this repo.
    xdg.dataFile = {
      "noctalia/plugins/glucose/plugin.toml".text = ''
        id = "dcosta/glucose"
        name = "Glucose Monitor"
        version = "1.0.0"
        plugin_api = 3
        author = "dcosta"
        description = "Latest blood glucose reading from Dexcom Share or Nightscout"

        # Plugin-level settings ([[setting]] at the manifest root, shared
        # across every entry the plugin defines) rather than per-widget-
        # instance ([[widget.setting]]) — credentials are plugin-wide, not
        # something you'd want a second copy of per widget instance. This
        # also matters mechanically: only root-level settings make
        # noctalia count the plugin as configurable, which is what puts a
        # configure gear in Settings > Plugins and makes
        # `noctalia.openSettings()` (used by this widget's right-click,
        # below) work at all — a plugin whose only settings live under
        # `[[widget.setting]]` gets "has no settings" and a silently
        # ignored openSettings() call instead.
        [[setting]]
        key = "source"
        type = "select"
        label_key = "settings.source.label"
        description_key = "settings.source.description"
        default = "dexcom"
        options = [
          { value = "dexcom", label_key = "settings.source.dexcom" },
          { value = "nightscout", label_key = "settings.source.nightscout" },
        ]

        [[setting]]
        key = "dexcom_username"
        type = "string"
        label_key = "settings.dexcom_username.label"
        description_key = "settings.dexcom_username.description"
        default = ""

        [[setting]]
        key = "dexcom_password"
        type = "string"
        label_key = "settings.dexcom_password.label"
        description_key = "settings.dexcom_password.description"
        default = ""

        [[setting]]
        key = "dexcom_region"
        type = "select"
        label_key = "settings.dexcom_region.label"
        description_key = "settings.dexcom_region.description"
        default = "us"
        options = [
          { value = "us", label_key = "settings.dexcom_region.us" },
          { value = "ous", label_key = "settings.dexcom_region.ous" },
        ]

        [[setting]]
        key = "nightscout_url"
        type = "string"
        label_key = "settings.nightscout_url.label"
        description_key = "settings.nightscout_url.description"
        default = ""

        [[setting]]
        key = "nightscout_token"
        type = "string"
        label_key = "settings.nightscout_token.label"
        description_key = "settings.nightscout_token.description"
        default = ""

        [[setting]]
        key = "mmol"
        type = "bool"
        label_key = "settings.mmol.label"
        description_key = "settings.mmol.description"
        default = false

        [[widget]]
        id = "glucose"
        entry = "glucose.luau"
      '';

      "noctalia/plugins/glucose/translations/en.json".text = builtins.toJSON {
        settings = {
          source = {
            label = "Source";
            description = "Where to pull glucose readings from";
            dexcom = "Dexcom Share";
            nightscout = "Nightscout";
          };
          dexcom_username = {
            label = "Dexcom username";
            description = "Dexcom account username (the one used in the Dexcom app, with Share enabled)";
          };
          dexcom_password = {
            label = "Dexcom password";
            description = "Dexcom account password";
          };
          dexcom_region = {
            label = "Dexcom region";
            description = "Use \"Outside US\" if your Dexcom account isn't a US account";
            us = "United States";
            ous = "Outside United States";
          };
          nightscout_url = {
            label = "Nightscout URL";
            description = "Base URL of your Nightscout site, no trailing slash (e.g. https://yoursite.example.com)";
          };
          nightscout_token = {
            label = "Nightscout API token";
            description = "Optional read-only token, sent as ?token=... if your site requires auth";
          };
          mmol = {
            label = "Show mmol/L";
            description = "Display glucose in mmol/L instead of mg/dL";
          };
        };
      };

      # `update()` runs on the interval set below and does an async
      # `noctalia.http` fetch of the latest entry; `onClick()` (bar left
      # click) re-runs it on demand. Reference: docs.noctalia.dev plugin API
      # (noctalia.* globals, barWidget.* setters — bar widgets specifically;
      # other entry kinds get their own table, e.g. desktopWidget/panel).
      "noctalia/plugins/glucose/glucose.luau".text = ''
        -- Glucose bar widget: polls either Dexcom Share or a Nightscout
        -- site (whichever is picked in this widget's own settings screen,
        -- not from Nix) and shows the latest sensor glucose reading with a
        -- trend arrow.
        --
        -- Dexcom Share note: the querying Dexcom account must have Share
        -- enabled with at least one follower added in the Dexcom app (even
        -- a throwaway one) — Dexcom's API silently returns no data
        -- otherwise. This is an undocumented quirk of the Share API, not a
        -- bug here.

        local TREND_ARROWS = {
          DoubleUp = "⇈",
          SingleUp = "↑",
          FortyFiveUp = "↗",
          Flat = "→",
          FortyFiveDown = "↘",
          SingleDown = "↓",
          DoubleDown = "⇊",
          NotComputable = "?",
          RateOutOfRange = "?",
          NONE = "?",
          None = "?",
        }

        local MGDL_TO_MMOL = 0.0555
        local STALE_MS = 15 * 60 * 1000 -- CGM entries normally land every 5 min

        -- Public Dexcom Share application id used by every third-party
        -- Share client (pydexcom, xDrip, nightscout-connect, ...) — not a
        -- secret, just an app identifier Dexcom's own Share/Follow apps
        -- also use.
        local DEXCOM_APPLICATION_ID = "d8665ade-9673-4e27-9ff6-92db4ce13d13"
        local DEXCOM_EMPTY_SESSION = "00000000-0000-0000-0000-000000000000"
        local DEXCOM_BASE_US = "https://share2.dexcom.com/ShareWebServices/Services"
        local DEXCOM_BASE_OUS = "https://shareous1.dexcom.com/ShareWebServices/Services"

        noctalia.setUpdateInterval(60000) -- poll once a minute, not the 250ms default

        -- Cached in-memory only: the script stays resident between
        -- update()/onClick() calls, so this survives across polls but not
        -- across a plugin reload (which is fine, login is cheap).
        local dexcomSessionId = nil

        local function showError(text, tooltip)
          barWidget.setText(text)
          barWidget.setColor("#e06c75", "script")
          barWidget.setTooltip(tooltip)
        end

        local function render(entry)
          local sgv = entry.sgv
          local useMmol = noctalia.getConfig("mmol")
          local value = useMmol and string.format("%.1f", sgv * MGDL_TO_MMOL) or string.format("%d", sgv)
          local arrow = TREND_ARROWS[entry.direction] or "?"
          local ageMs = noctalia.nowMs() - entry.date
          local stale = ageMs > STALE_MS

          local text = value .. " " .. arrow
          if stale then
            text = text .. " !"
          end
          barWidget.setText(text)

          if stale then
            barWidget.setColor("#e5c07b", "script")
          elseif sgv < 70 or sgv > 180 then
            barWidget.setColor("#e06c75", "script")
          else
            barWidget.setColor("on_surface", "auto")
          end

          barWidget.setTooltip(
            string.format("%d mg/dL, %s, %d min ago", sgv, entry.direction or "?", math.floor(ageMs / 60000))
          )
        end

        -- Dexcom Share ------------------------------------------------------

        local function dexcomBase()
          if noctalia.getConfig("dexcom_region") == "ous" then
            return DEXCOM_BASE_OUS
          end
          return DEXCOM_BASE_US
        end

        local function dexcomLogin(onDone)
          local username = noctalia.getConfig("dexcom_username")
          local password = noctalia.getConfig("dexcom_password")
          if username == nil or username == "" or password == nil or password == "" then
            onDone(nil, "set Dexcom username/password")
            return
          end

          noctalia.http({
            url = dexcomBase() .. "/General/LoginPublisherAccountByName",
            method = "POST",
            headers = { "Content-Type: application/json", "Accept: application/json" },
            body = noctalia.json.encode({
              accountName = username,
              password = password,
              applicationId = DEXCOM_APPLICATION_ID,
            }),
            follow_redirects = true,
          }, function(res)
            if not res.ok or res.status ~= 200 then
              onDone(nil, "Dexcom login failed (status " .. tostring(res.status) .. ")")
              return
            end

            local sessionId = noctalia.json.decode(res.body)
            if type(sessionId) ~= "string" or sessionId == "" or sessionId == DEXCOM_EMPTY_SESSION then
              onDone(nil, "Dexcom login rejected, check credentials")
              return
            end

            dexcomSessionId = sessionId
            onDone(sessionId)
          end)
        end

        local function dexcomReadLatest(sessionId, onDone)
          local url = dexcomBase()
            .. "/Publisher/ReadPublisherLatestGlucoseValues?sessionId="
            .. noctalia.string.urlEncode(sessionId)
            .. "&minutes=1440&maxCount=1"

          noctalia.http(
            { url = url, method = "POST", headers = { "Accept: application/json" }, follow_redirects = true },
            function(res)
              if not res.ok or res.status ~= 200 then
                onDone(nil)
                return
              end

              local data = noctalia.json.decode(res.body)
              if type(data) ~= "table" or data[1] == nil or data[1].Value == nil then
                onDone(nil)
                return
              end

              local entry = data[1]
              local ms = tonumber(string.match(entry.WT or "", "%((%d+)"))
              onDone({ sgv = entry.Value, direction = entry.Trend, date = ms or noctalia.nowMs() })
            end
          )
        end

        local function fetchDexcom()
          local function readWithSession(sessionId, allowRelogin)
            dexcomReadLatest(sessionId, function(reading)
              if reading ~= nil then
                render(reading)
                return
              end

              if allowRelogin then
                -- Session likely expired: drop the cache and log in fresh,
                -- once, before giving up.
                dexcomSessionId = nil
                dexcomLogin(function(newSessionId, err)
                  if newSessionId == nil then
                    showError("Dexcom: auth", err)
                    return
                  end
                  readWithSession(newSessionId, false)
                end)
              else
                showError("Dexcom: error", "Dexcom Share request failed")
              end
            end)
          end

          if dexcomSessionId ~= nil then
            readWithSession(dexcomSessionId, true)
          else
            dexcomLogin(function(sessionId, err)
              if sessionId == nil then
                showError("Dexcom: auth", err)
                return
              end
              readWithSession(sessionId, false)
            end)
          end
        end

        -- Nightscout (fallback) ----------------------------------------------

        local function fetchNightscout()
          local url = noctalia.getConfig("nightscout_url")
          if url == nil or url == "" then
            showError("NS: set URL", "Set the Nightscout URL in this widget's settings")
            return
          end

          local endpoint = url .. "/api/v1/entries.json?count=1"
          local token = noctalia.getConfig("nightscout_token")
          if token ~= nil and token ~= "" then
            endpoint = endpoint .. "&token=" .. noctalia.string.urlEncode(token)
          end

          noctalia.http({ url = endpoint, method = "GET", follow_redirects = true }, function(res)
            if not res.ok or res.status ~= 200 then
              showError("NS: error", "Nightscout request failed (status " .. tostring(res.status) .. ")")
              return
            end

            local data = noctalia.json.decode(res.body)
            if data == nil or data[1] == nil then
              showError("NS: --", "Nightscout returned no entries")
              return
            end

            render({ sgv = data[1].sgv, direction = data[1].direction, date = data[1].date })
          end)
        end

        -- --------------------------------------------------------------------

        local function fetch()
          if noctalia.getConfig("source") == "nightscout" then
            fetchNightscout()
          else
            fetchDexcom()
          end
        end

        function update()
          fetch()
        end

        function onClick()
          fetch()
        end

        -- Right click jumps straight to this plugin's own settings page
        -- (Settings > Plugins > Glucose Monitor) instead of making the
        -- user hunt for it.
        function onRightClick()
          noctalia.openSettings()
        end
      '';

      # GPU-mode bar widget: shows and cycles the auto/nvidia/intel
      # preference from modules/home/gpu-mode.nix. No plugin-level
      # [[setting]] here — there's nothing to configure, just a state file
      # to poll — so unlike the glucose plugin this one has no
      # Settings-page entry and onRightClick/openSettings() isn't wired up.
      "noctalia/plugins/gpu-switch/plugin.toml".text = ''
        id = "dcosta/gpu-switch"
        name = "GPU Mode"
        version = "1.0.0"
        plugin_api = 3
        author = "dcosta"
        description = "Toggle the preferred GPU (auto/nvidia/intel) for newly-launched apps"

        [[widget]]
        id = "gpu-switch"
        entry = "gpu-switch.luau"
      '';

      "noctalia/plugins/gpu-switch/gpu-switch.luau".text = ''
        -- Mirrors and cycles the state written by the `gpu-mode` CLI
        -- (modules/home/gpu-mode.nix). Purely a display/trigger for that
        -- script — this widget holds no GPU-switching logic of its own.

        local LABELS = {
          auto = "GPU: Auto",
          nvidia = "GPU: NVIDIA",
          intel = "GPU: Intel",
        }

        -- NVIDIA/Intel brand colors for at-a-glance state; "auto" uses the
        -- theme's own text color so it doesn't stand out when nothing is
        -- forced (same on_surface/"auto" convention as glucose.luau).
        local COLORS = {
          auto = { value = "on_surface", mode = "auto" },
          nvidia = { value = "#76b900", mode = "script" },
          intel = { value = "#0071c5", mode = "script" },
        }

        noctalia.setUpdateInterval(60000) -- state only changes from a click, no need to poll often

        local function render(mode)
          barWidget.setText(LABELS[mode] or ("GPU: " .. tostring(mode)))

          local c = COLORS[mode]
          if c ~= nil then
            barWidget.setColor(c.value, c.mode)
          end

          barWidget.setTooltip("Preferred GPU for newly-launched apps (click to cycle). Already-running apps are unaffected.")
        end

        local function trim(s)
          return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
        end

        function update()
          noctalia.runAsync("gpu-mode get", function(result)
            if result.exitCode == 0 then
              render(trim(result.stdout))
            end
          end)
        end

        function onClick()
          noctalia.runAsync("gpu-mode cycle", function(result)
            if result.exitCode == 0 then
              render(trim(result.stdout))
            end
          end)
        end
      '';
    };
  };
}
