def is_prime?(num)
  ('1' * num) !~ /^1?$|^(11+?)\1+$/
end

results = []
(10_000..13_000).each do |n|
  results << n if is_prime?(n)
end

p results.size
