TigerTech - XML Assignment 3 - Starter Files
============================================

PROVIDED (do not change):
  products.xml     the product catalog (from Assignments 1-2)
  categories.xml   the categories (from Assignments 1-2)
  orders.xml       NEW - customer orders; each <line> references a product by sku

YOU COMPLETE:
  report.xsl       the stylesheet - follow the TODO markers

Goal: transform orders.xml into an HTML order report. For each order line,
look up the product name, price, and category from the other files, show line
totals formatted as currency, and flag lines that exceed available stock.

Run it in IntelliJ (right-click report.xsl -> your XSLT run configuration with
orders.xml as the input). Graduates add XSLT 2.0 features and need Saxon-HE -
see the instruction sheet for setup. Full instructions and the rubric are in
the instruction sheet.
