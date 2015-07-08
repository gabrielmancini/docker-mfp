STOP: docker stop $(docker ps -a -q)
BUILD: docker build -t procurador/mfp .
RUN: docker run -p 10080:10080 -p 3000:3000 -v ~/workspace:/workspace -w /workspace/ProcuradorApp -t -i procurador/mfp
COOL LINE: :-)
docker stop $(docker ps -a -q) && docker build -t procurador/mfp . && docker run -p 10080:10080 -p 3000:3000 -v ~/workspace:/workspace -w /workspace/ProcuradorApp -t -i procurador/mfp
