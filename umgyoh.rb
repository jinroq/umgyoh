# coding: utf-8
class Umgyoh
  require "socket"

  # umgyoh pid ファイル
  UMGYOH_PID_FILE = "./tmp/umgyoh.pid".freeze
  # umgyoh log ファイル
  UMGYOH_LOG_FILE = "./tmp/umgyoh.log".freeze
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
      # デーモン化
      Process.daemon(true, true)

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
    @tcp_server = TCPServer.open(UMGYOH_DEFAULT_PORT)

    while true
      # 接続要求を受け付ける TCPSocket を生成。
      socket = @tcp_server.accept

      puts("socket.peeraddr => #{socket.peeraddr}")
      @log_file.puts("socket.peeraddr => #{socket.peeraddr}")

      while buf = socket.gets
        puts("buf => #{buf}")
        @log_file.puts("buf => #{buf}")

        socket.puts("200")
      end

      # TCPSocket を閉じる。
      socket.close
    end
  end

  def stop
    @tcp_server.close
  end
end

# 起動
Umgyoh.new.run
