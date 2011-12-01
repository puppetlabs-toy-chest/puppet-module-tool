# Return string containing the STDIN and STDOUT output emitted within
# the +block+.
def output_for(&block)
  output = StringIO.new

  stdout_old = $stdout
  stderr_old = $stderr

  $stdout = output
  $stderr = output

  block.call

  output.rewind
  return output.read
ensure
  $stdout = stdout_old
  $stderr = stderr_old
end
