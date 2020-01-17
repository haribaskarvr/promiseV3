public class Chain implements Finalizer {
  Promise[] promises;

  public Chain(Promise[] promises){
    this.promises = promises;
  }

  public void execute(FinalizerContext context){
    Id parentQueueableJobId = context.getAsyncApexJobId();
    switch on context.getAsyncApexJobResult() {
      when SUCCESS {
        // Queueable completed successfully
        System.Debug('Parent Queueable (Job ID: ' + parentQueueableJobId + '): completed successfully!');
        System.Debug('Enqueing next Promise');
        if(this.promises.size() > 0){
          Promise next = this.promises.remove(0);
          next.promises = this.promises;
          System.enqueueJob(next);
        }
      }
      when UNHANDLED_EXCEPTION {
        // Queueable completed with failure
        System.Debug('Parent Queueable (Job ID: ' + parentQueueableJobId + '): FAILED!');
        System.Debug('Parent Queueable Exception: ' + context.getAsyncApexJobException().getMessage());
      }
      when else {
        System.Debug('Unrecognized Enum found');
      }
    }    
  }
}