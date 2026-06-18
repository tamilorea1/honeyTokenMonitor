async function loadIncidents() {
    const response = await fetch('/incidents');
    const incidents = await response.json();

    const tbody = document.getElementById('incidents-body');
    tbody.innerHTML = '';

    incidents.forEach(incident => {
        const row = document.createElement('tr');

        // Incidents from the Lambda (IAM honeytoken) have alarm_name/reason.
        // Incidents from the Express app (HTTP trap) have source/path.
        const detail = incident.alarm_name
            ? `IAM Key — ${incident.reason || ''}`
            : `HTTP Trap — ${incident.path || ''}`;

        const cells = [
            incident.incident_id,
            incident.source || 'iam-honeytoken',
            detail,
            incident.ip || '-',
            incident.timeStamp || incident.time || '-'
        ];

        // textContent (not innerHTML) — treats data as plain text, never executable code
        cells.forEach(text => {
            const cell = document.createElement('td');
            cell.textContent = text;
            row.appendChild(cell);
        });

        tbody.appendChild(row);
    });
}

loadIncidents();
