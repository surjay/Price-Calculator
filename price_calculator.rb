# This was written using ruby 2.6.5

ITEM_PRICES = {
  'milk' => { price: 3.97, sale_quantity: 2, sale_price: 5.00 },
  'bread' => { price: 2.17, sale_quantity: 3, sale_price: 6.00 },
  'banana' => { price: 0.99 },
  'apple' => { price: 0.89 },
}

COL_LABELS = { item: 'Item', quantity: 'Quantity', price: 'Price' }

def print_header
  puts ''
  puts "#{COL_LABELS.values.map { |label| label.ljust(@max_width) }.join(' ') }"
  puts '--------------------------------'
end

def print_item(item, item_hash)
  quantity = item_hash[:quantity]
  total = "$#{item_hash[:price]}"

  puts "#{item.capitalize.ljust(@max_width)} #{quantity.to_s.ljust(@max_width)} #{total.ljust(@max_width)}"
end

# calculates total price and savings from sales promotion if applicable for a given item/quantity
def item_price(item, quantity)
  item_price = ITEM_PRICES[item]

  sale_quantity, sale_price = item_price.values_at(:sale_quantity, :sale_price)
  if sale_price && sale_quantity
    sale_groups, quantity_remainders = quantity.divmod(sale_quantity)
  else
    sale_groups = 0
    quantity_remainders = quantity
  end

  total_without_sale = quantity * item_price[:price]
  total_with_sale = sale_price.to_i * sale_groups.to_i
  remainder_total = quantity_remainders * item_price[:price]

  total = total_with_sale + remainder_total
  savings = total_without_sale - total

  [total, savings]
end

puts 'Please enter all the items purchased separated by a comma'
# get input, turn into array of allowable items, strip trailing/leading whitespace and lowercase all items
item_input = gets.chomp
allowable_items = ITEM_PRICES.keys
items = item_input.split(',').map { |i| i.strip.downcase }.select { |i| allowable_items.include?(i) }

# tally the item quantities
item_sets = items.each_with_object({}) do |item, hash|
  count = hash[item] || 0
  hash[item] = count + 1
end

# build item hash with quantities, prices and savings
all_prices = []
all_savings = []
item_sets.each do |item, quantity|
  total, savings = item_price(item, quantity)
  all_prices << total
  all_savings << savings
  item_sets[item] = { quantity: quantity, price: total, savings: savings }
end

# get generic max width for each cell
max_col_width = COL_LABELS.values.map(&:length).max
max_item_width = items.map(&:size).max
max_price = all_prices.max
@max_width = [(max_price.to_s.length + 1), max_item_width, max_col_width].max

# print the table with prices
print_header

item_sets.each do |key, value|
  print_item(key, value)
end

total_price = all_prices.sum.round(2)
total_savings = all_savings.sum.round(2)

puts ''
puts "Total price : $#{total_price}"
puts "You saved $#{total_savings} today."
