{
  catppuccin = {
    k9s = {
      enable = true;
      transparent = true;
    };
  };

  programs.k9s = {
    enable = true;

    aliases = {
      aliases = {
        dp = "deployments";
        sec = "v1/secrets";
        jo = "jobs";
        cr = "clusterroles";
        crb = "clusterrolebindings";
        ro = "roles";
        rb = "rolebindings";
        np = "networkpolicies";
      };
    };

    plugins = {
      krr = {
        shortCut = "Shift-K";
        description = "Get krr";
        scopes = ["deployments, daemonsets, statefulsets"];
        command = "bash";
        background = false;
        confirm = false;
        args = [
          "-c"
          "LABELS=$(kubectl get $RESOURCE_NAME $NAME -n $NAMESPACE --context $CONTEXT --show-labels | awk '{print $NF}' | awk '{if(NR>1)print}'); krr simple --cluster $CONTEXT --selector $LABELS; echo \"Press 'q' to exit\"; while : ; do read -n 1 k <&1; if [[ $k = q ]] ; then break; fi; done"
        ];
      };

      toggle-helmrelease = {
        shortCut = "Shift-T";
        confirm = true;
        scopes = ["helmreleases"];
        description = "Toggle to suspend or resume a HelmRelease";
        command = "bash";
        background = false;
        args = [
          "-c"
          "suspended=$(kubectl --context $CONTEXT get helmreleases -n $NAMESPACE $NAME -o=custom-columns=TYPE:.spec.suspend | tail -1); verb=$([ $suspended = \"true\" ] && echo \"resume\" || echo \"suspend\"); flux $verb helmrelease --context $CONTEXT -n $NAMESPACE $NAME | less -K"
        ];
      };

      toggle-kustomization = {
        shortCut = "Shift-T";
        confirm = true;
        scopes = ["kustomizations"];
        description = "Toggle to suspend or resume a Kustomization";
        command = "bash";
        background = false;
        args = [
          "-c"
          "suspended=$(kubectl --context $CONTEXT get kustomizations -n $NAMESPACE $NAME -o=custom-columns=TYPE:.spec.suspend | tail -1); verb=$([ $suspended = \"true\" ] && echo \"resume\" || echo \"suspend\"); flux $verb kustomization --context $CONTEXT -n $NAMESPACE $NAME | less -K"
        ];
      };

      reconcile-git = {
        shortCut = "Shift-R";
        confirm = false;
        description = "Flux reconcile";
        scopes = ["gitrepositories"];
        command = "bash";
        background = false;
        args = [
          "-c"
          "flux reconcile source git --context $CONTEXT -n $NAMESPACE $NAME | less -K"
        ];
      };

      reconcile-hr = {
        shortCut = "Shift-R";
        confirm = false;
        description = "Flux reconcile";
        scopes = ["helmreleases"];
        command = "bash";
        background = false;
        args = [
          "-c"
          "flux reconcile helmrelease --context $CONTEXT -n $NAMESPACE $NAME | less -K"
        ];
      };

      reconcile-helm-repo = {
        shortCut = "Shift-Z";
        description = "Flux reconcile";
        scopes = ["helmrepositories"];
        command = "bash";
        background = false;
        confirm = false;
        args = [
          "-c"
          "flux reconcile source helm --context $CONTEXT -n $NAMESPACE $NAME | less -K"
        ];
      };

      reconcile-oci-repo = {
        shortCut = "Shift-Z";
        description = "Flux reconcile";
        scopes = ["ocirepositories"];
        command = "bash";
        background = false;
        confirm = false;
        args = [
          "-c"
          "flux reconcile source oci --context $CONTEXT -n $NAMESPACE $NAME | less -K"
        ];
      };

      reconcile-ks = {
        shortCut = "Shift-R";
        confirm = false;
        description = "Flux reconcile";
        scopes = ["kustomizations"];
        command = "bash";
        background = false;
        args = [
          "-c"
          "flux reconcile kustomization --context $CONTEXT -n $NAMESPACE $NAME | less -K"
        ];
      };

      reconcile-ir = {
        shortCut = "Shift-R";
        confirm = false;
        description = "Flux reconcile";
        scopes = ["imagerepositories"];
        command = "sh";
        background = false;
        args = [
          "-c"
          "flux reconcile image repository --context $CONTEXT -n $NAMESPACE $NAME | less -K"
        ];
      };

      reconcile-iua = {
        shortCut = "Shift-R";
        confirm = false;
        description = "Flux reconcile";
        scopes = ["imageupdateautomations"];
        command = "sh";
        background = false;
        args = [
          "-c"
          "flux reconcile image update --context $CONTEXT -n $NAMESPACE $NAME | less -K"
        ];
      };

      trace = {
        shortCut = "Shift-P";
        confirm = false;
        description = "Flux trace";
        scopes = ["all"];
        command = "bash";
        background = false;
        args = [
          "-c"
          "resource=$(echo $RESOURCE_NAME | sed -E 's/ies$/y/' | sed -E 's/ses$/se/' | sed -E 's/(s|es)$//g'); flux trace --context $CONTEXT --kind $resource --api-version $RESOURCE_GROUP/$RESOURCE_VERSION --namespace $NAMESPACE $NAME | less -K"
        ];
      };

      get-suspended-helmreleases = {
        shortCut = "Shift-S";
        confirm = false;
        description = "Suspended Helm Releases";
        scopes = ["helmrelease"];
        command = "sh";
        background = false;
        args = [
          "-c"
          "kubectl get --context $CONTEXT --all-namespaces helmreleases.helm.toolkit.fluxcd.io -o json | jq -r '.items[] | select(.spec.suspend==true) | [.metadata.namespace,.metadata.name,.spec.suspend] | @tsv' | less -K"
        ];
      };

      get-suspended-kustomizations = {
        shortCut = "Shift-S";
        confirm = false;
        description = "Suspended Kustomizations";
        scopes = ["kustomizations"];
        command = "sh";
        background = false;
        args = [
          "-c"
          "kubectl get --context $CONTEXT --all-namespaces kustomizations.kustomize.toolkit.fluxcd.io -o json | jq -r '.items[] | select(.spec.suspend==true) | [.metadata.name,.spec.suspend] | @tsv' | less -K"
        ];
      };
    };

    settings = {
      k9s = {
        liveViewAutoRefresh = false;
        refreshRate = 2;
        maxConnRetry = 5;
        readOnly = false;
        noExitOnCtrlC = false;
        ui = {
          enableMouse = false;
          headless = false;
          logoless = false;
          crumbsless = false;
          reactive = false;
          noIcons = false;
        };
        skipLatestRevCheck = false;
        disablePodCounting = false;
        shellPod = {
          image = "busybox";
          namespace = "default";
          limits = {
            cpu = "100m";
            memory = "100Mi";
          };
        };
        imageScans = {
          enable = false;
          exclusions = {
            namespaces = [];
            labels = {};
          };
        };
        logger = {
          tail = 100;
          buffer = 5000;
          sinceSeconds = -1;
          textWrap = false;
          showTime = false;
        };
        thresholds = {
          cpu = {
            critical = 90;
            warn = 70;
          };
          memory = {
            critical = 90;
            warn = 70;
          };
        };
      };
    };
  };
}
