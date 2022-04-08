function set_form, array
  return, array[uniq(array, sort(array))]
end