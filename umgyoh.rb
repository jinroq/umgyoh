# coding: utf-8
class Umgyoh
  require "socket"

  # umgyoh pid ファイル
  UMGYOH_PID_FILE = "./umgyoh.pid".freeze
  # umgyoh log ファイル
  UMGYOH_LOG_FILE = "./umgyoh.log".freeze
  # umgyoh デフォルトポート番号
  UMGYOH_DEFAULT_PORT = 2019

  # 初期化処理
  def initialize
    # pid ファイル作成
    @pid_file = File.open(UMGYOH_PID_FILE, "w")
    # log ファイル作成
    @log_file = File.open(UMGYOH_LOG_FILE, "w")
  end

  # 起動
  def run
    begin
      @log_file.puts("== Umgyoh Begin.")

      # デーモン化
      daemonize

      # 処理実行
      execute

      @log_file.puts("== Umgyo End.")
    rescue => e
    end
  end

  private

  # デーモン化
  def daemonize
    begin
      Process.daemon

      # pid ファイル生成
      @pid_file = File.open(UMGYOH_PID_FILE, "w") { |f| f << Process.pid }
    rescue => e
      error_message = "Error. #{self.class.name}.daemonize #{e}"
      @log_file.puts(error_message)
      STDERR.puts(error_message)
      exit(1)
    end
  end

  # 処理実行
  def execute
    tcp_server = TCPServer.open(2019)

    while true
      sock = tcp_server.accept

      puts("#{sock.peeraddr}")
      @log_file.puts("#{sock.peeraddr}")

      while buf = sock.gets
        puts("#{buf}")
        @log_file.puts("#{buf}")
      end
    end

    tcp_server.close
  end
end

# 起動
Umgyoh.new.run
