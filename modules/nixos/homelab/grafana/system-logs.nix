{ lokiUid }:
{
  id = null;
  uid = "system-logs";
  title = "System Logs";
  tags = [
    "loki"
    "systemd"
    "vanaheim"
  ];
  timezone = "browser";
  schemaVersion = 38;
  version = 1;
  refresh = "30s";
  time = {
    from = "now-1h";
    to = "now";
  };

  # Dropdown to filter by systemd unit
  templating.list = [
    {
      name = "host";
      label = "Host";
      type = "query";
      datasource = {
        type = "loki";
        uid = lokiUid;
      };
      definition = "label_values(host)";
      query = {
        query = "label_values(host)";
        refId = "LokiVariableQueryEditor-VariableQuery";
      };
      refresh = 2;
      multi = true;
      includeAll = true;
      allValue = ".+";
      current = {
        selected = true;
        text = "All";
        value = "$__all";
      };
    }
    {
      name = "unit";
      label = "Unit";
      type = "query";
      datasource = {
        type = "loki";
        uid = lokiUid;
      };
      definition = "label_values({job=\"systemd-journal\",host=~\"$host\"},unit)";
      query = {
        query = "label_values({job=\"systemd-journal\",host=~\"$host\"},unit)";
        refId = "LokiVariableQueryEditor-VariableQuery";
      };
      refresh = 2;
      multi = true;
      includeAll = true;
      allValue = ".+";
      current = { };
    }
  ];

  panels = [
    # Log rate over time, split by unit
    {
      id = 1;
      type = "timeseries";
      title = "Log Rate by Unit (logs/s)";
      gridPos = {
        h = 8;
        w = 24;
        x = 0;
        y = 0;
      };
      datasource = {
        type = "loki";
        uid = lokiUid;
      };
      targets = [
        {
          datasource = {
            type = "loki";
            uid = lokiUid;
          };
          expr = "sum by(unit) (rate({job=\"systemd-journal\",host=~\"$host\"}[5m]))";
          legendFormat = "{{unit}}";
          refId = "A";
        }
      ];
      fieldConfig = {
        defaults = {
          custom = {
            drawStyle = "line";
            lineInterpolation = "linear";
            spanNulls = false;
            fillOpacity = 10;
          };
          unit = "short";
          min = 0;
        };
        overrides = [ ];
      };
      options = {
        tooltip = {
          mode = "multi";
          sort = "desc";
        };
        legend = {
          displayMode = "table";
          placement = "bottom";
          calcs = [
            "sum"
            "max"
          ];
        };
      };
    }

    {
      id = 2;
      type = "logs";
      title = "Log Lines";
      gridPos = {
        h = 16;
        w = 24;
        x = 0;
        y = 8;
      };
      datasource = {
        type = "loki";
        uid = lokiUid;
      };
      targets = [
        {
          datasource = {
            type = "loki";
            uid = lokiUid;
          };
          expr = "{host=~\"$host\"}";
          refId = "A";
        }
      ];
      options = {
        showTime = true;
        showLabels = false;
        showCommonLabels = false;
        wrapLogMessage = true;
        prettifyLogMessage = false;
        enableLogDetails = true;
        sortOrder = "Descending";
        dedupStrategy = "none";
      };
    }
  ];
}
