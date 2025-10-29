---
title: 🚀 Deployment Approval Request - QA Environment
labels: deployment, approval-required, qa
assignees: 
---

## 📋 Deployment Information

**Environment:** QA  
**Branch:** `{{ env.BRANCH }}`  
**Run Number:** `{{ env.RUNNUMBER }}`  
**Requested by:** @{{ env.ACTOR }}  
**Timestamp:** {{ date | date('YYYY-MM-DD HH:mm:ss UTC') }}

---

## ✅ Pre-Deployment Checklist

- [ ] All tests passed successfully
- [ ] Code review completed
- [ ] No critical security issues
- [ ] Database migrations reviewed (if applicable)
- [ ] Rollback plan confirmed

---

## 🎯 Deployment Target

**Environment:** QA  
**URL:** https://qa.ejemplo.com  
**Version:** Check workflow run #{{ env.RUNNUMBER }}

---

## 📊 Changes Summary

This deployment includes changes from the latest QA tests and PR creation.

**Review the workflow run:** [Click here](https://github.com/${{ github.repository }}/actions/runs/{{ env.RUNNUMBER }})

---

## 🚦 Approval Instructions

To **approve** this deployment, comment on this issue with:

```
Approved
```

To **reject** this deployment, close this issue with a comment explaining the reason.

---

## ⚠️ Important Notes

- Once approved, the deployment will start automatically
- The deployment process typically takes 5-10 minutes
- You will receive a notification when the deployment completes
- This issue will be closed automatically after successful deployment

---

## 🔍 Related Resources

- [Deployment Documentation](https://github.com/${{ github.repository }}/wiki/Deployment)
- [Rollback Procedure](https://github.com/${{ github.repository }}/wiki/Rollback)
- [QA Environment Status](https://status.qa.ejemplo.com)

---

<!-- deployment_payload
{
  "environment": "qa",
  "runNumber": "{{ env.RUNNUMBER }}",
  "branch": "{{ env.BRANCH }}",
  "requestedBy": "{{ env.ACTOR }}"
}
-->

**⏰ This approval request will expire in 24 hours**