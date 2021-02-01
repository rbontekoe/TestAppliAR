function template(t::String)
    """
    <!DOCTYPE html>
    <html lang="en">
        <head>
            <title>BAWJ</title>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon" />
            <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
            <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
            <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

            <style>
                table, th, td {
                    border: 1px solid black;
                    padding: 0.5em;
                    border-collapse: collapse;
                }
                div{
                    margin: 1em;
                }
            </style>
        </head>
        <body>
            <nav class="navbar navbar-expand-md bg-dark navbar-dark">
            <!-- Brand -->
            <a class="navbar-brand" href="#"><img src="/logo.png" width="50"/> AppliGate</a>
    
            <!-- Toggler/collapsibe Button -->
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#collapsibleNavbar">
            <span class="navbar-toggler-icon"></span>
            </button>
    
            <!-- Navbar links -->
                <div class="collapse navbar-collapse" id="collapsibleNavbar">
                    <ul class="navbar-nav">
                        <li class="nav-item">
                            <a class="nav-link" href="/">Home</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="/agingreport">Aging Report</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="/gl?account=1300">GL Report</a>
                        </li>
                    </ul>
                </div>
            </nav>
          
            <div>
                $(t)
            </div>
          
        </body>
    </html>
    """
end

function index(c::WebController)
    render(HTML, template("""
    <h2>Hello World!</h2>
    <p>This is the example from the course <a href='https://www.appligate.nl/BAWJ/stable/'>BAWJ</a>. In chapter 13 the student
    learns to create two Docker containers. The containers are used in this website.</p>
    <p>The website can also started from a <a href='https://github.com/rbontekoe/TestAppliAR/blob/master/website.ipynb'>IJulia Notebook</a>. This gives the user more opportunities to experiment.<p>
    """))
end

function aging_report(c::WebController)
  r = @fetchfrom ar_pid report()
  result = 
  """
    <h1>Aging Report</h1>
    <table>
    <th>Invoice</th><th>Date</th><th>Customer</th><th>Amount</th><th>Age</th>
  """
  for n = 1:length(r)
    result = result * """
      <tr>
        <td>$(r[n].id_inv)</td>
        <td>$(Date(r[n].inv_date))</td><td>$(r[n].csm)</td>
        <td style='text-align:right'>$(r[n].amount)</td>
        <td>$(r[n].days)</td>
      </tr>"""
  end
  result = result * "</table>"
  render(HTML, template("$(result)"))
end

function gl(c::WebController)
    account = "$(c.params.account)"
    r0 = @fetchfrom gl_pid AppliGeneralLedger.read_from_file("./test_ledger.txt")
    r = r0 |> @filter(_.accountid == parse(Int64, account))
    debit = []
    credit = []
    result = """
<h2>Valid Accounts</h2>
<a href='/gl?account=1300'>Accounts Receivable - 1300</a></br>
<a href='/gl?account=1150'>Bank - 1150</a></br>
<a href='/gl?account=8000'>Sales - 8000</a></br>
<a href='/gl?account=4000'>VAT - 4000</a></br><hr>
<h2>Account $(account)</h2>
<table>
<th>Invoice</th><th>Date</th><th>Customer</th><th>Debit</th><th>Credit</th><th>Descr</th>"""
for n in r
  result = result * """
    <tr>
      <td>$(n.invoice_nbr)</td>
      <td>$(Date(n.date))</td>
      <td>$(n.customerid)</td>
      <td style='text-align: right'>$(n.debit)</td>
      <td style='text-align: right'>$(n.credit)</td>
      <td>$(n.descr)</td>
    </tr>"""
    push!(debit, n.debit)
    push!(credit, n.credit)
end
sum_debit = sum(debit)
sum_credit = sum(credit)
balance = sum_credit - sum_debit
balance = balance >= 0 ? balance : -balance
result = result * "<tr><td></td><td></td><td></td><td style='text-align: right'>$sum_debit</td><td style='text-align: right'>$sum_credit</td><td></td></tr></table><p>Balance: $balance"
    render(HTML, template("$(result)"))
end

function test(c::WebController)
  @info("A: $(c.conn.request)")
  @info("B: $(c.conn.request.headers)")
  @info("C: $(c.params.v)")
  render(HTML, template("<h2>Een test</h2><p>Request: $(c.conn.request)</p><p>Headers: $(c.conn.request.headers)</p><p>Parameters: $(c.params.v)</p>"))
end

function favicon(c::WebController)
    A = Char.(read("favicon.ico"))
    y = reduce( (x, y) -> x * y, A)
    render(HTML, y)
end