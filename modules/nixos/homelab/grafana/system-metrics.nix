{ prometheusUid }:
{
  id = null;
  uid = "system-metrics";
  title = "System Metrics";
  tags = [
    "prometheus"
    "node"
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

  panels = [
    # CPU usage
    {
      id = 1;
      type = "timeseries";
      title = "CPU Usage %";
      gridPos = {
        h = 8;
        w = 12;
        x = 0;
        y = 0;
      };
      datasource = {
        type = "prometheus";
        uid = prometheusUid;
      };
      targets = [
        {
          datasource = {
            type = "prometheus";
            uid = prometheusUid;
          };
          expr = "100 - (avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)";
          legendFormat = "CPU";
          refId = "A";
        }
      ];
      fieldConfig = {
        defaults = {
          unit = "percent";
          min = 0;
          max = 100;
          custom = {
            drawStyle = "line";
            lineInterpolation = "linear";
            fillOpacity = 10;
          };
        };
        overrides = [ ];
      };
      options = {
        tooltip = {
          mode = "single";
        };
        legend = {
          displayMode = "list";
          placement = "bottom";
        };
      };
    }

    # Memory usage
    {
      id = 2;
      type = "timeseries";
      title = "Memory Usage %";
      gridPos = {
        h = 8;
        w = 12;
        x = 12;
        y = 0;
      };
      datasource = {
        type = "prometheus";
        uid = prometheusUid;
      };
      targets = [
        {
          datasource = {
            type = "prometheus";
            uid = prometheusUid;
          };
          expr = "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100";
          legendFormat = "Memory";
          refId = "A";
        }
      ];
      fieldConfig = {
        defaults = {
          unit = "percent";
          min = 0;
          max = 100;
          custom = {
            drawStyle = "line";
            lineInterpolation = "linear";
            fillOpacity = 10;
          };
        };
        overrides = [ ];
      };
      options = {
        tooltip = {
          mode = "single";
        };
        legend = {
          displayMode = "list";
          placement = "bottom";
        };
      };
    }

    # Network I/O
    {
      id = 3;
      type = "timeseries";
      title = "Network I/O";
      gridPos = {
        h = 8;
        w = 24;
        x = 0;
        y = 8;
      };
      datasource = {
        type = "prometheus";
        uid = prometheusUid;
      };
      targets = [
        {
          datasource = {
            type = "prometheus";
            uid = prometheusUid;
          };
          expr = "rate(node_network_receive_bytes_total{device!=\"lo\"}[5m])";
          legendFormat = "rx {{device}}";
          refId = "A";
        }
        {
          datasource = {
            type = "prometheus";
            uid = prometheusUid;
          };
          expr = "rate(node_network_transmit_bytes_total{device!=\"lo\"}[5m])";
          legendFormat = "tx {{device}}";
          refId = "B";
        }
      ];
      fieldConfig = {
        defaults = {
          unit = "Bps";
          custom = {
            drawStyle = "line";
            lineInterpolation = "linear";
            fillOpacity = 5;
          };
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
            "mean"
            "max"
          ];
        };
      };
    }

    # Disk usage gauge
    {
      id = 4;
      type = "gauge";
      title = "Disk Usage";
      gridPos = {
        h = 8;
        w = 12;
        x = 0;
        y = 16;
      };
      datasource = {
        type = "prometheus";
        uid = prometheusUid;
      };
      targets = [
        {
          datasource = {
            type = "prometheus";
            uid = prometheusUid;
          };
          expr = "(1 - node_filesystem_avail_bytes{mountpoint=\"/\",fstype!~\"tmpfs|overlay|ramfs\"} / node_filesystem_size_bytes{mountpoint=\"/\",fstype!~\"tmpfs|overlay|ramfs\"}) * 100";
          legendFormat = "{{mountpoint}}";
          refId = "A";
          instant = true;
        }
      ];
      fieldConfig = {
        defaults = {
          unit = "percent";
          min = 0;
          max = 100;
          thresholds = {
            mode = "absolute";
            steps = [
              {
                color = "green";
                value = null;
              }
              {
                color = "yellow";
                value = 75;
              }
              {
                color = "red";
                value = 90;
              }
            ];
          };
        };
        overrides = [ ];
      };
      options = {
        reduceOptions = {
          calcs = [ "lastNotNull" ];
        };
        orientation = "auto";
        showThresholdLabels = false;
        showThresholdMarkers = true;
      };
    }

    # System load
    {
      id = 5;
      type = "timeseries";
      title = "System Load";
      gridPos = {
        h = 8;
        w = 12;
        x = 12;
        y = 16;
      };
      datasource = {
        type = "prometheus";
        uid = prometheusUid;
      };
      targets = [
        {
          datasource = {
            type = "prometheus";
            uid = prometheusUid;
          };
          expr = "node_load1";
          legendFormat = "1m";
          refId = "A";
        }
        {
          datasource = {
            type = "prometheus";
            uid = prometheusUid;
          };
          expr = "node_load5";
          legendFormat = "5m";
          refId = "B";
        }
        {
          datasource = {
            type = "prometheus";
            uid = prometheusUid;
          };
          expr = "node_load15";
          legendFormat = "15m";
          refId = "C";
        }
      ];
      fieldConfig = {
        defaults = {
          unit = "short";
          min = 0;
          custom = {
            drawStyle = "line";
            lineInterpolation = "linear";
            fillOpacity = 5;
          };
        };
        overrides = [ ];
      };
      options = {
        tooltip = {
          mode = "multi";
          sort = "desc";
        };
        legend = {
          displayMode = "list";
          placement = "bottom";
        };
      };
    }
  ];
}
