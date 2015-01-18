def fibonacci index
  return 1 if index <= 2

  fibonacci(index - 1) + fibonacci(index - 2)
end

def lucas index
  return 2 if index == 1
  return 1 if index == 2

  lucas(index - 1) + lucas(index - 2)
end

def series series_name, index
  case series_name
    when "fibonacci" then fibonacci(index)
    when "lucas"     then lucas(index)
    when "summed"    then lucas(index) + fibonacci(index)
  end
end
