# main.jl - running the applications as website with the Bukdu web framework.

using Pkg

Pkg.activate(".")

using Bukdu, Distributed, Query, Dates

# start the containers
cmd = `docker restart test_sshd`
run(cmd)
cmd = `docker restart test_sshd2`
run(cmd)

# get ip the addresses of the containers
cmd_sshd = `docker inspect -f '{{ .NetworkSettings.IPAddress }}' test_sshd`
cmd_sshd2 = `docker inspect -f '{{ .NetworkSettings.IPAddress }}' test_sshd2`
ip_sshd = read(cmd_sshd, String)
ip_sshd2 = read(cmd_sshd2, String)
ip_sshd = ip_sshd[1:length(ip_sshd)-1] # strip \n
ip_sshd2 = ip_sshd2[1:length(ip_sshd2)-1] # strip \n

# connect to the containers
addprocs([("rob@" * ip_sshd, 1)]; exeflags=`--project=$(Base.active_project())`, tunnel=true, dir="/home/rob")
addprocs([("rob@" * ip_sshd2, 1)]; exeflags=`--project=$(Base.active_project())`, tunnel=true, dir="/home/rob")
gl_pid = procs()[2] # general ledger
ar_pid = procs()[3] # accounts receivable (invoices/bankstatements)
@everywhere using AppliSales
@everywhere using AppliGeneralLedger
@everywhere using AppliAR
@everywhere using Query

# configure website
struct WebController <: ApplicationController
  conn::Conn
end

include("functions.jl");

routes() do
  get("/", WebController, index)
  get("/agingreport", WebController, aging_report)
  get("/gl", WebController, gl)
  get("/test/:v", WebController, test)
end

Bukdu.start(8004, host="0.0.0.0")
