require 'aruba/api'

module Roby
    module Test
        # Minitest-usable Aruba wrapper
        #
        # Aruba 0.14 is incompatible with Minitest because of their definition
        # of the #run method This change hacks around the problem, by moving
        # the Aruba API to a side stub object.
        #
        # The run methods are renamed as they have been renamed in Aruba 1.0
        # alpha, run -> run_command and run_simple -> run_command_and_stop
        module ArubaMinitest
            class API
                include ::Aruba::Api
            end

            def setup
                super
                @aruba_api = API.new
                @aruba_api.setup_aruba
            end

            def teardown
                stop_all_commands
                super
            end

            def run_command_and_stop(*args, fail_on_error: true)
                cmd = run_command(*args)
                cmd.stop
                if fail_on_error
                    assert_command_finished_successfully(cmd)
                end
                cmd
            end

            def run_command(*args)
                @aruba_api.run(*args)
            end

            def method_missing(m, *args, &block)
                if @aruba_api.respond_to?(m)
                    return @aruba_api.send(m, *args, &block)
                else
                    super
                end
            end

            def assert_command_stops(cmd, fail_on_error: true)
                cmd.stop
                if fail_on_error
                    assert_command_finished_successfully(cmd)
                end
            end

            def assert_command_finished_successfully(cmd)
                assert_equal 0, cmd.exit_status, "#{cmd} finished with a non-zero exit status (#{cmd.exit_status})\n-- STDOUT\n#{cmd.stdout}\n-- STDERR\n#{cmd.stderr}"
            end
        end
    end
end