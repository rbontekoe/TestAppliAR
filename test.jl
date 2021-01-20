@info("Enable distrbuted computing")
using Distributed

@info("Connect to containers")
addprocs([("rob@172.17.0.2", 1)]; exeflags=`--project=$(Base.active_project())`, tunnel=true, dir="/home/rob")
addprocs([("rob@172.17.0.3", 1)]; exeflags=`--project=$(Base.active_project())`, tunnel=true, dir="/home/rob")

@info("Assign process ids to the containers")
gl_pid = procs()[2] # general ledger
ar_pid = procs()[3] # accounts receivable (orders/bankstatements)


@everywhere using AppliSales
@everywhere using AppliGeneralLedger
@everywhere using AppliAR
@everywhere using Query

# Example
r1 = @fetchfrom ar_pid report()
