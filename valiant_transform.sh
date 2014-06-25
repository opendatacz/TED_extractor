#!/bin/bash

printHelp() {

  echo "Script expects installed Valiant tool (for executing XSLT) and his configuration file is located in /etc/valiant/"

  echo "Arguments:"
  echo "-s, --source\t\t Source dir with xml documents"
  echo "-d, --destination\t Target dir for trasmormed documents"
  echo "-x, --xslt \t\t Path to xslt file"
  echo "-g, --graph \t\t Target graph URI where results will be loaded"
  
  echo "Arguments for login to Virtuoso":
  echo "-s, --port \t\t Server port"
  echo "-u, --user \t\t Username"
  echo "-p, --password \t\t Password"
  
  echo "If -g, -d, -s, -u, -p arguments is present. Result will be uploaded to Virtuoso"
  
  EXECUTE=0
}

CONFIG_FILE=/etc/valiant/valiant.properties

EXECUTE=1

if [ $# -eq 0 ]; then
  printHelp
  
fi

#parsing parameters
while [ $# -gt 0 ]
do

  key="$1"
  shift

  case $key in
      -s|--source)
      REPLACEMENT_VALUE="$1"
      TARGET_KEY="inputfile"
      shift
      ;;
      -d|--destination)
      REPLACEMENT_VALUE="$1"
      TARGET_DIR="$1"
      TARGET_KEY="rdfFolder"
      shift
      ;;
      -x|--xslt)
      REPLACEMENT_VALUE="$1"
      TARGET_KEY="xslPath"
      shift
      ;;
      -g|--graph)
      REPLACEMENT_VALUE="$1"
      TARGET_GRAPH="$1"
      TARGET_KEY="baseURI"
      shift
      ;;
      -s|--port)
      VIRT_PORT="$1"
      shift
      ;;
      -u|--username)
      VIRT_USERNAME="$1"
      shift
      ;;
      -p|--password)
      VIRT_PASSWORD="$1"
      shift
      ;;
      -h|--help)
      printHelp
      ;;
      *)
      # unknown option
      ;;
  esac

  if [ -n "$REPLACEMENT_VALUE" ]; then
    sudo sed -i "s@^\($TARGET_KEY\s*=\s*\).*\$@\1$REPLACEMENT_VALUE@" $CONFIG_FILE
  fi

  REPLACEMENT_VALUE=

done

#executing transformation
if [ $EXECUTE -eq 1 ]; then
  echo "Executing Valiant transform"
  sudo valiant
  find $TARGET_DIR -name '*.graph' -delete

  #loading data to Virtuoso
  if [ -n "$TARGET_DIR" ] && [ -n "$TARGET_GRAPH" ] && [ -n "$VIRT_PORT" ] && [ -n "$VIRT_USERNAME" ] && [ -n "$VIRT_PASSWORD" ]; then
    echo "Loading data to Virtuoso"
    
isql-vt -S $VIRT_PORT -U $VIRT_USERNAME -P $VIRT_PASSWORD <<EOF
log_enable(3,1);
SPARQL CLEAR GRAPH <$TARGET_GRAPH>;
DELETE from DB.DBA.load_list WHERE ll_state=2;
ld_dir('$TARGET_DIR','*.rdf','$TARGET_GRAPH');
rdf_loader_run();
exit;
EOF

  fi

fi
