package ai.zeroon.memory;

import ai.zeroon.record.RecordCommittedEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Component
public class RecordMemoryProductionListener {

    private static final Logger log = LoggerFactory.getLogger(RecordMemoryProductionListener.class);

    private final MemoryProductionService memoryProductionService;

    public RecordMemoryProductionListener(MemoryProductionService memoryProductionService) {
        this.memoryProductionService = memoryProductionService;
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onRecordCommitted(RecordCommittedEvent event) {
        try {
            memoryProductionService.ensureForRecord(event.userId(), event.recordId());
        } catch (RuntimeException exception) {
            log.warn(
                    "event=record_memory_production_failed user_id={} record_id={} error_type={}",
                    event.userId(),
                    event.recordId(),
                    exception.getClass().getSimpleName());
        }
    }
}
