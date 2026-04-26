import ChronoSystem
import ChronoTZGenCore

func main() {
    do {
        let cli = try CLI()

        let packer = Packer(sourceDir: cli.inputDir)
        let context = try packer.process()

        let emitter: Emitter = cli.format.emitter
        try emitter.emit(ctx: context, to: cli.outputPath)
    } catch let error as FileSystemError {
        print(error.message)
        System.terminate(1)
    } catch let error as CLIError {
        print(error.message)
        System.terminate(1)
    } catch let error as PackerError {
        print(error.message)
        System.terminate(1)
    } catch {
        print("An unexpected error occurred: \(error)")
        System.terminate(1)
    }
}

main()
