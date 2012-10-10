module TLearn
  NUMBER_OF_OUTPUT_VECTORS = 1750  
  NUMBER_OF_RESET_TIMEPOINTS = 3497
  NUMBER_OF_INPUT_VECTORS_TO_FOLLOW = 3497

  WORKING_DIR = File.dirname(__FILE__) + '/../data'
  
  class << self
  
    def learn
      setup_config
      setup_data
      execute_tlearn

      if !File.exists?("#{WORKING_DIR}/evaluator.#{NUMBER_OF_OUTPUT_VECTORS}.wts")
        puts "[Error] Training failed"
      end
    end
    
    private

    def execute_tlearn
      `cd #{WORKING_DIR} && ../bin/tlearn -f evaulator -V -L -X -s 1752`
    end

    def setup_config
      File.open("#{WORKING_DIR}/evaulator.cf",    "w") {|f| f.write(evaulator_config)}
    end

    def setup_data
      File.open("#{WORKING_DIR}/evaulator.reset", "w") {|f| f.write(reset_config)}
      File.open("#{WORKING_DIR}/evaulator.data",  "w") {|f| f.write(data)}
      File.open("#{WORKING_DIR}/evaulator.teach", "w") {|f| f.write(teach_data)}
    end
  
    def evaulator_config
      nodes_config = {
        :nodes => 86,
        :inputs => 77,
        :outputs => 6,
        :output_nodes => '41-46'
      }
      connections_config = {
        :groups => 0,
        '1-81' => '0',
        '1-40' => 'i1-i77',
        '41-46' => '1-40',
        '1-40' =>  '47-86',
        '47-86' => ' 1-40 = 1. & 1. fixed one-to-one'
      }
      special_config = {
        :linear => '47-86',
        :weight_limit => '1.00',
        :selected => '1-86'
      }

      output_nodes = nodes_config.delete(:output_nodes)
      node_config_strings = nodes_config.map{|key,value| "#{key.to_s.gsub('_',' ')} = #{value}" }
      node_config_strings << "output nodes are #{output_nodes}"

      groups = connections_config.delete(:groups)
      connection_config_strings = connections_config.map{|key,value| "#{key} from #{value}" }
      connection_config_strings =  ["groups = #{groups}"] + connection_config_strings

      config = <<EOS
  NODES:
  #{node_config_strings.join("\n")}
  CONNECTIONS:
  #{connection_config_strings.join("\n")}
  SPECIAL:
  #{special_config.map{|key,value| "#{key} = #{value}" }.join("\n")}
EOS
    end

    def data
      data_file = <<EOS
  distributed
  #{NUMBER_OF_INPUT_VECTORS_TO_FOLLOW}
EOS
    end

    def teach_data
      teach_file = <<EOS
  distributed
  #{NUMBER_OF_OUTPUT_VECTORS}
EOS
    end
  
    def reset_config
      reset_file = <<EOS
  #{NUMBER_OF_RESET_TIMEPOINTS}
EOS
    end
  
  end
  
end